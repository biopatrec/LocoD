function [outSignal, outPressureSig, outTags,sigMask] = DeleteBadRounds(signal, originalPressureSignal, tags, fs, goodSeq)


% This script effectively zeros and rejects the EMG signal (and associated
% information, such as pressure sensor signal, tags) outside regions having
% a specific consequtive sequence of tags.

disp('DeleteBadRounds -- Loading signal')


%stem(signalCopy.tags(2,:),signalCopy.tags(1,:),'black'); ylim([0 8])

% Preferred tag sequence (depends on experiment)
disp('DeleteBadRounds -- Processing')
SearchSeq=goodSeq;
SearchSeqLen=length(SearchSeq);

% How much signal length to allow to be extracted outside the sequence
% boundaries.
TimeAfterLastWalk=5; %seconds
TimeBeforeFirstStair=3;

% Find such occurences of the sequence
SeqHitIndices=strfind(tags(1,:),SearchSeq);
NumHits = length(SeqHitIndices);

%signal=[];

% Some variable initiations
outTags = [];
%~~PressureSensor=[];
%~~diffIndex=(diff(index)>8);

% The sigMask vector specifies which parts of the signal to keep (0 or 1)
lenSig = length(signal);
sigMask = zeros(1, lenSig);

% Iterate over all regions having the search-sequence tags
for i=1:length(SeqHitIndices)
    % Select the tags in this region
    hit = SeqHitIndices(i);
    tagsSelected = tags(:,hit : hit+SearchSeqLen-1);

    % !@! Note that obviously tagsSelected(1,:)==SearchSeq

    % Store the selected tags in the output
    outTags = [outTags, tagsSelected];
    %~~tagsNew(:,(i-1)*SearchSeqLen+1:i*SearchSeqLen)=signalCopy.tags(:,SeqHitIndices(i):SearchSeqLen+SeqHitIndices(i)-1);

    % Unmask the signal in this region to keep.
    % Reminder: Row 2 in tag matrix indicates tag time.
    nS = (tagsSelected(2,  1) - TimeBeforeFirstStair) * fs;
    nE = (tagsSelected(2,end) + TimeAfterLastWalk   ) * fs;

    nS = ClampAB(floor(nS), 1, lenSig);
    nE = ClampAB(floor(nE), 1, lenSig);
    sigMask(1,nS:nE)=1;
end

% Mask/Unmask signal and store new tags
outSignal=sigMask.*signal;
outPressureSig=sigMask.*originalPressureSignal;

% Indicate new tag markers for test
if true
    figure('Name', "Tag Sequence Verification")
    subplot(3,1,1)
    stem(tags(2,:),tags(1,:),'red'); ylim([0 10]);
    hold on
    stem(outTags(2,:),outTags(1,:),'blue'); ylim([0 10]);
    hold off
    title("Blue: Passed Sequence")

    tSignal = (0:lenSig-1) / fs;
    subplot(3,1,2)
    plot(tSignal, outPressureSig, 'r')
    title("Passed Pressure Sig")

    subplot(3,1,3)
    plot(tSignal, outSignal(1,:), 'g')
    title("Passed ch#1 as an example")
end
end
