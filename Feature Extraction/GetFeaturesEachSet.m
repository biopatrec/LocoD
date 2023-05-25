%Get features from one set of data like test data
function    [Features,Lables,Lables_TransitionORSteady,Prevtag]=GetFeaturesEachSet(data,recprops,FetureSet,SignalType)

numwindow=size(data,3);
sF=recprops.SamplingFreq;
if SignalType=="EMG"
   ChIdx=recprops.IdxEMG;
   
elseif SignalType=="IMU"
   ChIdx=recprops.IdxIMU; 
  
elseif SignalType=="PS"
    ChIdx=recprops.IdxPS; 
    
end
numAllCh=recprops.NumAllCh;
Desireddata=data(ChIdx,:,:);


%Get Features

for i = 1 :numwindow
    f = GetSigFeatures(Desireddata(:,:,i),sF,FetureSet');
%     if i == 1
%         % To initialize the struct-array:
%       Features(:,i) = f;
%     end
    Features(:,i) = f; 
    Lables(:,i)=data(numAllCh+1,1,i);
    Lables_TransitionORSteady(:,i)=data(numAllCh+2,1,i);
    Prevtag(:,i)=data(numAllCh+4,1,i);
end
% allFeatureNames=fieldnames(f);
% OutputFeatures=[];
% Output=[];
% %Filter features
% for k=1:length(Features)  % number of windows
%     for i=1:length(FetureSet)  % number of all the extracted features
%         for j=1:length(allFeatureNames)
%             if strcmp(allFeatureNames(j),FetureSet(i))==1
%                 ExtractedFeatures = extractfield(Features(k),FetureSet(i));
%                 Output=[Output,ExtractedFeatures];
%             end
%             
%         end
%          
%     end
%    
%    OutputFeatures(k,:)=Output;
%    Output=[];
% end

      Features=squeeze(cell2mat(struct2cell(Features)))';      

end