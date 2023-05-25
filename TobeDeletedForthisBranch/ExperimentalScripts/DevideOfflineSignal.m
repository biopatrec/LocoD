% Load the signal data from a file
clear all
load('U:\LLP\LocoD-Github\SavedData\UsableData\Offline\TF005-09052022_2.mat')

% Split the signal into 80% train and 20% test
signallength = length(signalCopy.signal);
offline_length = round(0.8*signallength);
OfflineSignal = signalCopy;
OnlineSignal = signalCopy;

% Split the signal and tags into train and test sets
OfflineSignal.signal = signalCopy.signal(:,1:offline_length);
OnlineSignal.signal = signalCopy.signal(:,offline_length+1:end);

% Find the tag indices within the offline and online sets
fs = signalCopy.recProps.SamplingFreq;
for i=1:length(signalCopy.tags)
    if signalCopy.tags(2,i)*fs>= offline_length 
        OfflineTagLength=i;
        break
    end
end
offline_tag_indices = 1:OfflineTagLength;
online_tag_indices = OfflineTagLength+1:length(signalCopy.tags);



%Copy the tags
st=signalCopy.tags;
OfflineSignal.tags =st(:,offline_tag_indices);




%Copy Online Tags and Shift the times in online tags

OnlineSignal.tags = st(:,online_tag_indices);
OnlineSignal.tags(2,:) = OnlineSignal.tags(2,:)-st(2,OfflineTagLength);

%Split Pressure sensor data
OfflineSignal.originalPressureSignal = signalCopy.originalPressureSignal(:,1:offline_length);
OnlineSignal.originalPressureSignal = signalCopy.originalPressureSignal(:,offline_length+1:end);



