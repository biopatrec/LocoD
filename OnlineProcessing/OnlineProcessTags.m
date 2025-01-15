global BATCHOPERATIONS

close all
%clear all
clearvars -except BATCHOPERATIONS

haveFigure = 0;
dispResult = 1;

%This Script will take the predicted tags and true tags that was keyed in
%by the operator(True Tags) and claculate the classification accuracy in different
%movements and by taking into account that prediction can happend before or
%after the true tags.

% Check if this is part of a batch
if ~isempty(BATCHOPERATIONS)
    haveFigure = 0; % No figures in batch
    dispResult = 0; % No printing of results
end

if isempty(BATCHOPERATIONS)
    % load("U:\LLP\LocoD-Github\SavedData\gprdata.mat")
    % Load Replay data
    %load('U:\LLP\LocoD-Github\SavedData\PostProcessing\Majority Vote\TF004_MV.mat')
    % Load online data
    %load('U:\LLP\LocoD-Github\SavedData\UsableData\Real-time\TF001-05102022_3_Online2.mat')
    %load('U:\LLP\LocoD-Github\SavedData\UsableData\Real-time\Tf004-31082022_4_Online_2.mat')
    %load('U:\LLP\LocoD-Github\SavedData\UsableData\Real-time\TF005-09052022Online_2.mat')
    %load('U:\LLP\LocoD-Github\SavedData\UsableData\Real-time\TF006-12102022-2-Online.mat')
    load('U:\LLP\LocoD-Github\SavedData\UsableData\Real-time\TF008-16112022_1_Online_1.mat')
    %load('U:\LLP\LocoD-Github\SavedData\_st_6.mat')
else
load("U:\LLP\LocoD-Github\SavedData\" + BATCHOPERATIONS.current.fileName)
end

% We don't need the actual signal if there is no plotting involved. We just
% need its size.
if ~haveFigure
    sigLen = size(signalCopy.signal, 2);
    signalCopy.signal = zeros(0, sigLen);
    signalCopy.originalPressureSignal = zeros(0, sigLen);
end

%Delet true tags that do not follow the correct rounds
GoodTagSequence = LOCO.StandardTagSeq;
SamplingFreq=signalCopy.recProps.SamplingFreq;
[~, ~, TrueLabels, goodMask] = DeleteBadRounds(signalCopy.signal,signalCopy.originalPressureSignal,signalCopy.tags,SamplingFreq,GoodTagSequence,haveFigure);

PredictedTags=signalCopy.PredictedtagsOnline;

%Delete bad rounds for predicted tags
for j=1:length(PredictedTags)
    tagSample = PredictedTags(2, j);
    tagSample = round(tagSample); % We know tagSample is int, but let's make sure.
    if goodMask(tagSample) == 0
        % This tag falls on a "bad" signal region. Use the previous tag.
        if j~=1
            subtag= PredictedTags(1,j-1);
        elseif j==1
            subtag= GoodTagSequence(1);
        end
        PredictedTags(1,j)=subtag;
    end
end

% Add transitions for the part that has been modified due to tags that has been deleted in the previouse section...
% because it didnt followed the rounds we had in the lab
NewTagsOnline = zeros(2, length(PredictedTags));
for nr=1:length(PredictedTags)
    if nr ~= 1 && nr~=length(PredictedTags) && ...
      PredictedTags(1,nr)~=PredictedTags(1,nr+1) && ...
      LOCO.IsTagS(PredictedTags(1,nr)) && LOCO.IsTagS(PredictedTags(1,nr+1))
        % Record a transition
        Transition = LOCO.TagT(PredictedTags(1,nr), PredictedTags(1,nr+1));
        NewTagsOnline(1:2,nr)=[Transition; PredictedTags(2,nr)];
    else
        % Record a non-transition
        NewTagsOnline(1:2,nr)=PredictedTags(1:2,nr);
    end
end
PredictedTags=NewTagsOnline;

% There are situations where two identical transition-tags are predicted
% immediately after eachother. Set the latter to a non-transition-tag.
for nr=1:length(PredictedTags)
    if nr~=length(PredictedTags) && LOCO.IsTagT(PredictedTags(1,nr)) && PredictedTags(1,nr)==PredictedTags(1,nr+1)
        PredictedTags(1,nr+1)=LOCO.TagSN(PredictedTags(1,nr+1));
    end
end

% Align true tags with gait phase
TrueTags=AlignTagsWithGait(TrueLabels,signalCopy.GaitTransitionsOnline,SamplingFreq);

% A simple test to make sure data is correct and compatible.
if any(TrueTags(2,:) ~= signalCopy.GaitTransitionsOnline(2,:)) || ...
  any(PredictedTags(2,:) ~= signalCopy.GaitTransitionsOnline(2,:))
    error(['Fault: TrueTags and PredictedTags must be exactly aligned at gait' ...
        ' transition timings.'])
end

% The lame way of processing online accuracy
onlineaccuBefore=sum((TrueTags(1,:))==PredictedTags(1,:))/length(PredictedTags);

%% Look for transitions in the neighboring true tags
% in this case we look to see if same true transition happend in the previous Np gaits or in the next Nn gaits
% TODO: Explain what we are doing here.
numGait = length(TrueTags(1,:));
Np=2; %2
Nn=3;  %3
Neighbors = InterleavedNeighborIndex(Nn, Np); % 0,1,-1,2,-2,3
TrueTagsAligned = TrueTags; %make a copy
j = 1;
T_X = 0;
for g=1:numGait
    PredTagType = PredictedTags(1, g);
    if LOCO.IsTagS(PredTagType)
        % For this technique, ignore the steady state tags.
        continue
    end

    PredTagSmp = PredictedTags(2, g);
    [PrevPredTag, NextPredTag] = LOCO.TagS(PredTagType);

    % Find a neighboring tag (in terms of gaits) in True Tags which
    %   indicates same transition.
    for gOffset=Neighbors
        if g + gOffset <= 0 || g + gOffset > numGait
            % Out of range
            continue
        end
        if PredTagType == TrueTags(1, g + gOffset)
            % X
            % Same truetag transition found.
            % Make sure that there is no other TrueTag transitions between
            %   gait #i and gait #(i+offset).
            if any(TrueTags(1, g+gOffset+1:g-1) ~= NextPredTag) || ...
               any(TrueTags(1, g+1:g+gOffset-1) ~= PrevPredTag)
                continue
            end

            TrueTagSmp = TrueTags(2, g + gOffset);

            % Move the truetag so it sits at same gait as predtag
            TrueTagsAligned(1, g) = PredTagType;
            TrueTagsAligned(1, g+1:g+gOffset) = NextPredTag; % for offset >= 0
            TrueTagsAligned(1, g+gOffset:g-1) = PrevPredTag; % for offset < 0

            %Store prediction time which is the time between key pressed and prediction
            predictonTimeArray(1:2,j)= [
                (PredTagSmp - TrueTagSmp)/SamplingFreq;
                PredTagType,
            ];
            j = j + 1;
            
            % Don't look for more neighbors
            break
        end
    end
end

% Get mean prediction time
meanPredictonTime=mean(predictonTimeArray(1,:));
stdPredictonTime=std(predictonTimeArray(1,:));

% Get ready to plot results.
% For sake of visualization, zero the correct predictions.
% In order to plot zero the true predictions
ZTrueTagsAligned=TrueTagsAligned;
ZPredictedTags=PredictedTags;
IncorrectPredictions = TrueTagsAligned(1,:) ~= PredictedTags(1,:);

ZTrueTagsAligned(1,:) = TrueTagsAligned(1,:) .* IncorrectPredictions;
ZPredictedTags(1,:) = PredictedTags(1,:) .* IncorrectPredictions;

if haveFigure
    figure
    %Plot predicted tags
    stem(ZPredictedTags(2,:),ZPredictedTags(1,:));
    hold on;
    %Plot true tags
    stem(ZTrueTagsAligned(2,:),ZTrueTagsAligned(1,:));
    hold on;
    %Plot Gait
    stairs(signalCopy.GaitTransitionsOnline(2,:),signalCopy.GaitTransitionsOnline(1,:));
    hold on;
    
    % stairs(TrueLabelsOnline(2,:),TrueLabelsOnline(1,:));
    % hold on
    % stem(PredictedtagsOnline(2,:),PredictedtagsOnline(1,:));
    legend("Predicted","True","Gait")%,"True","Predicted");
    
    figure
    subplot(3,1,1)
    %Plot predicetd tags
    stem(ZPredictedTags(2,:),ZPredictedTags(1,:));
    hold on;
    %Plot true tags
    stem(ZTrueTagsAligned(2,:),ZTrueTagsAligned(1,:));
    legend("Predicted","True");
    subplot(3,1,3)
    stairs(signalCopy.GaitTransitionsOnline(2,:),signalCopy.GaitTransitionsOnline(1,:));
    subplot(3,1,2)
    stem(PredictedTags(2,:),PredictedTags(1,:)); 
    hold on
    stairs(TrueTagsAligned(2,:),TrueTagsAligned(1,:));
    
    legend("Predicted","True");
end

%% Calculate Accuracy
onlineaccu=sum((TrueTagsAligned(1,:)==PredictedTags(1,:) & TrueTagsAligned(1,:)~=0))/sum(TrueTagsAligned(1,:)~=0);

% Calculate Teansition and Steady State accuracy
ss=1;
tr=1;

TrueLabTR = [];
PredictedLabTR = [];
TrueLabSS = [];
PredictedLabSS = [];

for j=1:length(TrueTagsAligned)
    if LOCO.IsTagT(TrueTagsAligned(1,j)) %Transition
        TrueLabTR=[TrueLabTR, TrueTagsAligned(1,j)];
        PredictedLabTR=[PredictedLabTR, PredictedTags(1,j)];
    elseif TrueTagsAligned(1,j)~=0
        TrueLabSS=[TrueLabSS, TrueTagsAligned(1,j)];
        PredictedLabSS=[PredictedLabSS, PredictedTags(1,j)];
    end
end

onlineAccuTRMean=mean(TrueLabTR==PredictedLabTR);
onlineAccuSSMean=mean(TrueLabSS==PredictedLabSS);


%Calculate prediction time for each transition type
%Calculate accuracy for each movement in transition type
locoTrans = LOCO.TCommonTransitions';
predTimes = [];
onlineAccuTR = [];
stdpredTimes=[];
predictonTimeArray(1,:)=predictonTimeArray(1,:)-.1; %Minuse the 100 miliseconds that we waited to get data after each gait phase
for TT = locoTrans'
    predTimes = [predTimes; mean(predictonTimeArray(1, predictonTimeArray(2,:) == TT))];
    stdpredTimes = [stdpredTimes; std(predictonTimeArray(1, predictonTimeArray(2,:) == TT))];

    onlineAccuTR = [onlineAccuTR; 100 * sum(TrueLabTR==PredictedLabTR & TrueLabTR==TT) / sum(TrueLabTR==TT)];
end

%Calculate accuracy of prediction during entire steady state
locoModes = LOCO.TLocoModes';
onlineAccuSS = [];
for SS = locoModes'
    onlineAccuSS = [onlineAccuSS; 100 * sum(TrueLabSS==PredictedLabSS & TrueLabSS==SS) / sum(TrueLabSS==SS)];
end

if dispResult
    predTimes = 1000 *predTimes;
    stdpredTimes = stdpredTimes*1000;
    Neighbors
    onlineaccu
    meanPredictonTime
    onlineAccuTRMean
    onlineAccuSSMean
    disp(table(locoTrans, predTimes,stdpredTimes,onlineAccuTR));
    disp(table(locoModes, onlineAccuSS));
    onlineaccuBefore
    onlineaccu
end

%% Plot For Paper
if haveFigure
    figure
    hold on
    TransitionTagsTrue=find(TrueTagsAligned(1,:)==34);
    stairs(signalCopy.GaitTransitionsOnline(2,:)/2000,signalCopy.GaitTransitionsOnline(1,:)-89,LineWidth=1.2)
    stem(TrueTagsAligned(2,TransitionTagsTrue)/2000,(TrueTagsAligned(1,TransitionTagsTrue)./TrueTagsAligned(1,TransitionTagsTrue)).*12,Color='r',LineWidth=2);
    xticks(1 :600)
    xticklabels(repmat(1:10,1,60))
end

%Make the grey Area
