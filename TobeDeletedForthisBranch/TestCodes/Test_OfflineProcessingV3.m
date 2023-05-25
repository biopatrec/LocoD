clear all
recprops = RecordingProperties();
signal = Signal(recprops);

%% Load Signal
data = signal.LoadSignal();
Fs=data.recProps.SamplingFreq;
sF=Fs;
numCh=data.recProps.NumAllCh;
signal=data.signal;

%signal= signal+(max(signal(1,:))/10)* rand(1, length(signal));
%figure
%plot(signal(1,:))




%% Filter Signal

%Notch
N   = 6;  % Order
Fc1 = 49;  % First Cutoff Frequency
Fc2 = 51;  % Second Cutoff Frequency

[z,p,k] = butter(N/2, [Fc1 Fc2]/(Fs/2), 'stop');

[sos_var,g] = zp2sos(z, p, k);
Hd50        = dfilt.df2sos(sos_var, g);

signal = filter(Hd50,signal);


% Bandpass filter
N   = 4;     % Order
FC1=20;
FC2=400;

% Calculate the zpk values using the BUTTER function.
[z,p,k] = butter(N/2, [FC1 FC2]/(Fs/2));

[sos_var,g] = zp2sos(z, p, k);
Hd          = dfilt.df2sos(sos_var, g);
%signal      = filtfilt(sos_var,g,signal);
signal      = filter(Hd,signal);



%% Split the data into the time windows

% Add tags to data
tags=data.tags;
[AvailableTagName, eventDataWithTags]=SignalTagger(signal,tags,numCh,Fs);
%Tagnames=get_tag_name(AvailableTagName);
%save('Tagnames','Tagnames')
nM=length(unique(eventDataWithTags(numCh+1,:)));
%nM   =numMovements* (numMovements-1) ;        % Number of events
eventLen_Transition = 1.2;
eventLen_Static=1.2;
eventOffset_Transition=-0.2;
tWindow=0.2;
tOverlap=0.05;

nEventLen_Transition = round(eventLen_Transition * Fs);  % Samples per event
nEventLen_Static=round(eventLen_Static * Fs);  % Samples per event;
nWSamples=round(tWindow * Fs); % Samples corresponding Time window
nOverlap=round(tOverlap * Fs);   % Samples correcponding overlap
nNonOverlap = nWSamples - nOverlap;

nW_Transition= floor(nEventLen_Transition/(nWSamples-nOverlap) ) ;    %number of windows per event
nW_Static= floor(nEventLen_Static/(nWSamples-nOverlap) ) ;

% Check if final window fits actually
if nW_Transition * nNonOverlap + nOverlap > nEventLen_Transition
    nW_Transition = nW_Transition - 1;
end

%signal=signal';
%datawithtags=zeros(length(tags(1,:)),size(signal,1),size(signal,2));

i=1;
ns=1;
uniquetags=unique(eventDataWithTags(numCh+1,:),'stable');

% Separate events just 30 seconds for each event

NewData=[];
NewStaticData=[];
for s=1:length(eventDataWithTags)
    
    if i<=length(uniquetags) && eventDataWithTags(numCh+1,s)==uniquetags(i) && s>500
 
        if uniquetags(i)>=10        %% It was a transition
                   nEventStart = s+ eventOffset_Transition * Fs;
        nEventEnd = nEventStart + nEventLen_Transition - 1;
            TransitionData= eventDataWithTags(1:numCh,nEventStart:nEventEnd);
            TransitionData(numCh+1,:)= uniquetags(i);
           % plot(TransitionData(numCh+1,:));
            NewData=[NewData, TransitionData ];
            
        else
            nEventStart = s+ 1000;
             nEventEnd = nEventStart + nEventLen_Transition - 1;
            StaticData = eventDataWithTags(:,nEventStart:nEventEnd);
            %plot(StaticData(numCh+1,:));
            NewData=[NewData ,StaticData];
            
        end
        i=i+1;
    end
end

% Reshape data into 3 dimension
NewData=NewData';
numTransition=length(unique(NewData(:,numCh+1)));
%numStatic=length(unique(NewStaticData(:,numCh+1)));
%numStatic=4;
%Static=unique(NewStaticData(:,numCh+1));
Trans=unique(NewData(:,numCh+1));
nStart=0;
b=[];
for i=1:numTransition
    a=NewData(nStart+1:nStart+length(TransitionData),:);
    nStart=nStart+length(TransitionData);
    b=cat(3,a,b);
end
NewData=b;

% Separate windows of events in data
windowedData = [];
for e = 1 : numTransition
    for i = 1 : nW_Transition
        iidx = 1 + (nNonOverlap * (i-1));
        eidx = nWSamples + (nNonOverlap *(i-1));
        windowedData(:,:,e,i) = NewData(iidx:eidx,:,e);
    end
end


%40,40,20 Transition
trSets = round(.4*nW_Transition);
vSets   = round(.2*nW_Transition);
tSets  = nW_Transition - trSets - vSets; %floor(.4*nW);
trdata= windowedData(:,:,:,1:trSets);
vdata   = windowedData(:,:,:,trSets+1:trSets+vSets);
tdata  = windowedData(:,:,:,trSets+vSets+1:trSets+vSets+tSets);



%% Feature Extraction 
labelI = 0;
for m = 1: numTransition
    for i = 1 :trSets
        trFeatures(i,m) = GetSigFeatures(trdata(:,1:numCh,m,i),sF);
        labelI = labelI + 1;
        trLables(labelI)=trdata(1,numCh+1,m,i);
    end
    
end

labelI = 0;
for m = 1: numTransition
    for i = 1 : vSets
        vFeatures(i,m) = GetSigFeatures(vdata(:,1:numCh,m,i),sF);
        labelI = labelI + 1;
        vLables(labelI)=vdata(1,numCh+1,m,i);
    end
end

labelI = 0;
for m = 1: numTransition
    for i = 1 : tSets
        tFeatures(i,m) = GetSigFeatures(tdata(:,1:numCh,m,i),sF);
        labelI = labelI + 1;
        tLables(labelI)=tdata(1,numCh+1,m,i);
    end
end

%% Get sets

tLables=tLables';
Ntrset = trSets* (numTransition);
Nvset  = vSets  * (numTransition);
Ntset  = tSets  *  (numTransition);

features = ["tmabs",'twl' ,'tzc', 'tslpch2' ];

trSet = zeros(Ntrset, length(features));
vSet  = zeros(Nvset , length(features));
tSet  = zeros(Ntset , length(features));

clear e

for eventIndex = 1 :  (numTransition)
    e = eventIndex;
    % Training
    for r = 1 : trSets
        sidx = r + (trSets*(e-1));
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(trFeatures(r,e).(features{i}));
            trSet(sidx,li:le) = trFeatures(r,e).(features{i}); % Get each feature per channel
            li = le + 1;
        end
        %trOut(sidx,j) = 1;
    end
    % Validation
    for r = 1 : vSets
        sidx = r + (vSets*(e-1));
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(vFeatures(r,e).(features{i}));
            vSet(sidx,li:le) = vFeatures(r,e).(features{i});
            li = le + 1;
        end
        %   vOut(sidx,j) = 1;
    end
    % Test
    for r = 1 : tSets
        sidx = r + (tSets*(e-1));
        li = 1;
        for i = 1 : length(features)
            le = li - 1 + length(tFeatures(r,e).(features{i}));
            tSet(sidx,li:le) = tFeatures(r,e).(features{i});
            li = le + 1;
        end
       
    end
end


%% Classification
%% Randomize data (if requested)???

%%%%%%%%%%Labels
%   trLables=trdata(:,numCh+1,1,1);
%   tLables=tdata(:,numCh+1,1,1);
%   vLables=vdata(:,numCh+1,1,1);

%Apply discriminat to vset9
dType='linear';
trLables=trLables';




try
    %[vLabelsPredicted,err,POSTERIOR,logp,coeff] = classify(vSet,trSet,trLables,dType);
    classifierModel = fitcdiscr(trSet, trLables, 'DiscrimType', 'pseudoLinear');
    vLabelsPredicted = predict(classifierModel, vSet);
catch e
    disp(e)
    errordlg(e.message);
    accVset = [];
    coeff = [];
    return;
end

numCorrect = sum(vLabelsPredicted == vLables');
accTotal = numCorrect / Nvset;
correctPrediction = zeros(Nvset,1);

C = confusionmat(vLabelsPredicted, vLables);
confusionchart(C);

%%%%%%%%%%%%%%%55
%What about fitcdiscr and predict

%%%%%%%%%%5555


%[tLabelsPredicted,err,POSTERIOR,logp,coeff] = classify(tSet,trSet,trLables,dType);
 classifierModel = fitcdiscr(trSet, trLables, 'DiscrimType', 'pseudoLinear');
 tLabelsPredicted = predict(classifierModel, tSet);
 save('classifierModel','classifierModel');
D = confusionmat(tLabelsPredicted, tLables);
cm = plotconfusion(tLables,tLabelsPredicted);
%figure();
%confusionchart(D);
return;


    
    %  x = NormalizeSet(tSet(i,:), patRec);
    %x = ApplyFeatureReduction(x, patRec);
    
    
    

    

   



