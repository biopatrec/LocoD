%Get features from each window
function    [OutputFeatures]=GetFeaturesEachWindow(data,recprops,FetureSet,SignalType)

sF=recprops.SamplingFreq;

if SignalType=="EMG"
   ChIdx=recprops.IdxEMG;
elseif SignalType=="IMU"
   ChIdx=recprops.IdxIMU; 
elseif SignalType=="PS"
   ChIdx=recprops.IdxPS; 
end

Desireddata=data(ChIdx,:,:);



%Get Features

f = GetSigFeatures(Desireddata(:,:),sF);
Features = f;
allFeatureNames=fieldnames(f);
OutputFeatures=[];
Output=[];
%Filter features
for k=1:length(Features)  % number of windows
    for i=1:length(FetureSet)  % number of all the extracted features
        for j=1:length(allFeatureNames)
            if strcmp(allFeatureNames(j),FetureSet(i))==1
                ExtractedFeatures = extractfield(Features(k),FetureSet(i));
                Output=[Output,ExtractedFeatures];
            end
            
        end
         
    end
   
   OutputFeatures(k,:)=Output;
   Output=[];
end

% for eventIndex = 1 : this.numTransition

end