clear all
recprops = RecordingProperties();
signal = Signal(recprops);

%% Load Signal
data = signal.LoadSignal();
Fs=data.recProps.SamplingFreq;
sF=Fs;
numCh=data.recProps.NumChannels;
signal=data.signal;




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
%data      = filtfilt(sos_var,g,data);
signal      = filter(Hd50,signal);



%% Split the data into the time windows %%%%%%%%%%%CHECK THIS SECTION
tags=data.tags;

nM   =5;%length(tags(1,:)) ;        % Number of events
eventLen = 1.2;
eventOffset=-0.2;
tWindow=0.1;
tOverlap=0.025;

nEventLen = round(eventLen * Fs);  % Samples per event
nWSamples=round(tWindow * Fs); % Samples corresponding Time window
nOverlap=round(tOverlap * Fs);   % Samples correcponding overlap
nNonOverlap = nWSamples - nOverlap;

nW= floor(nEventLen/(nWSamples-nOverlap) ) ;    %number of windows per event
% Check if final window fits actually
if nW * nNonOverlap + nOverlap > nEventLen
    nW = nW - 1;
end

signal=signal';
%datawithtags=zeros(length(tags(1,:)),size(signal,1),size(signal,2));

% Separate events
for i=1:nM %!@! nM
    nEventStart = floor((tags(2,i) + eventOffset) * Fs + 0.5);
    nEventEnd = nEventStart + nEventLen - 1;
    a=signal(nEventStart:nEventEnd,:); % Get event signal
    b=tags(1,i)*ones(nEventLen,1);
    
    eventDataWithTags=[a b];
    if i==1
        allEvents = eventDataWithTags;
    else
        allEvents = cat(3,allEvents,eventDataWithTags);
    end
    
end
eventDataWithTags=allEvents;

% Separate windows of events
windowedData = [];
for e = 1 : nM
    for i = 1 : nW
        iidx = 1 + (nNonOverlap * (i-1));
        eidx = nWSamples + (nNonOverlap *(i-1));
        windowedData(:,:,e,i) = eventDataWithTags(iidx:eidx,:,e);
    end
end

%40,40,20
trSets  = round(.4*nW);
vSets   = round(.2*nW);
tSets   = nW - trSets - vSets; %floor(.4*nW);
trdata  = windowedData(:,:,:,1:trSets);
vdata   = windowedData(:,:,:,trSets+1:trSets+vSets);
tdata   = windowedData(:,:,:,trSets+vSets+1:trSets+vSets+tSets);

%% Feature Extraction
labelI = 0;
for m = 1: nM
    for i = 1 :trSets
        trFeatures(i,m) = GetSigFeatures(trdata(:,1:numCh,m,i),sF);
        labelI = labelI + 1;
        trLables(labelI)=trdata(1,numCh+1,m,i);
    end
    
end

labelI = 0;
for m = 1: nM
    for i = 1 : vSets
        vFeatures(i,m) = GetSigFeatures(vdata(:,1:numCh,m,i),sF);
        labelI = labelI + 1;
        vLables(labelI)=vdata(1,numCh+1,m,i);
    end
end

labelI = 0;
for m = 1: nM
    for i = 1 : tSets
        tFeatures(i,m) = GetSigFeatures(tdata(:,1:numCh,m,i),sF);
        labelI = labelI + 1;
        tLables(labelI)=tdata(1,numCh+1,m,i);
    end
end

%% Get sets

tLables=tLables';
Ntrset = trSets * nM;
Nvset  = vSets  * nM;
Ntset  = tSets  * nM;

features = ["tmabs",'twl' ,'tzc', 'tslpch2' ];

trSet = zeros(Ntrset, length(features));
vSet  = zeros(Nvset , length(features));
tSet  = zeros(Ntset , length(features));
%
% trOut = zeros(Ntrset, nM);
% vOut  = zeros(Nvset , nM);
% tOut  = zeros(Ntset , nM);

% Stack window feature together in a continous signal instead of different
% dimensions
clear e

for eventIndex = 1 : nM
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
        %tOut(sidx,j) = 1;
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
    [class,err,POSTERIOR,logp,coeff] = classify(vSet,trSet,trLables,dType);
catch e
    errordlg(e.Message);
    accVset = [];
    coeff = [];
    return;
end

%nM   = size(mov,1);
good = zeros(size(vSet,1),1);
sM   = size(vSet,1)/nM;  % set per movement, NOTE this is done assuming that
% the movements have equal amount of sets (rows)

% Run the DiscrimnantTest for each testing Set
numCorrect = sum(class == vLables')
accTotal = numCorrect / Nvset

%% Calculate accuracy


   %%Check, not sure
        confMatFlag=1;
        nOut=length(coeff);
        confMat = zeros(length(coeff),nOut+1);
        maskMat = zeros(size(tSet,1),nOut)
       
for i = 1 : size(tSet,2)
    
    %% Classification
    %for i = 1 : size(tSet,2)
        
       %  x = NormalizeSet(tSet(i,:), patRec);
    %x = ApplyFeatureReduction(x, patRec);
        
        %OneShotPatRecClassifier
        
        
        %tempRes = zeros(nM,nM);
        for k = 1 : length(coeff)
            for j = 1 : length(coeff)
                if k ~= j
                    K = coeff(k,j).const;
                    L = coeff(k,j).linear;
                    tempRes(k,j) = K + tSet(i,:) * L;      % k + f1*L1 + f2*L2 ......
                end
            end
        end
        
        outVector = sum(tempRes,2);
        [maxV, outMov] = max(outVector);
        
        
        
        %% Count the number of correct predictions
        if ~isempty(outMov)
            if outMov ~= 0
                % Create a mask to match the correct output
                mask = zeros(1,nOut);
                mask(outMov) = 1;
                % Save the mask for future computation of prediction metrics
                maskMat(i,:)=mask;
                % Are these the right movements?
                if tLables(i,:) == mask
                    good(i) = 1;
                else
                    %stop for debuggin purposes
                end
                
                
            else
                %If outMov = 0, then count it for the confusion matrix as no
                %prediction in an additional output
                outMov = nOut+1;
            end
        else
            %If outMov = empty, then count it for the confusion matrix as no
            %prediction in an additional output
            outMov = nOut+1;
        end
        
     
        %Confusion Matrix
        if confMatFlag
            expectedOutIdx = fix((i-1)/sM)+1;   % This will only work if there is an equal number of sets per class
            confMat(expectedOutIdx,outMov) = confMat(expectedOutIdx,outMov) + 1;
        end
    end
    
%end

% Verify that dimension of maskMat and tOut match
if size(tSet,1) ~= size(maskMat,1)
    disp('error in maskMat');
end
if size(tSet,1) ~= size(tOut,1)
    disp('error in tOut');
end


% Compute metrics per movement/class
% This will only work if there are the same number of movements
acc     = zeros(nM+1,1);
for i = 1 : nM
    s = 1+((i-1)*sM);
    e = sM*i;
    acc(i) = sum(good(s:e))/sM;
    
end
acc(i+1) = sum(good) / size(tSet,1);

% Save performance metrics
performance.acc = acc*100;

% Print confusion matrix
if confMatFlag
    confMat = confMat ./ sM; % This will only work if there is an equal number of sets per class
    figure;
    imagesc(confMat);
    title('Confusion Matrix')
    xlabel('Movements');
    ylabel('Movements');
end



