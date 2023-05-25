%Get features from one set of data like test data
function    [Featurcell,Lables,Lables_TransitionORSteady,Prevtag]=GetFeaturesEachRound(data,recprops,FetureSet,numrounds,SignalType)
Featurcell={};
%numwindow=size(data,3);
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


IdxRound=numAllCh+3;

%Get Features

for r=1:numrounds
   
        ind= (data(IdxRound,1,:)==r);
        datarounds{r,:}=Desireddata(:,:,ind);
    
end
for r=1:numrounds
    
numwindow=size(datarounds{r,:},3);

Desireddata=datarounds{r};
for i = 1 :numwindow
    
    f = GetSigFeatures(Desireddata(:,:,i),sF,FetureSet');
%     if i == 1
%         % To initialize the struct-array:
%        Features{r,:} = f;
%     end
    Features(:,i) = f; 
    Lables{r,i}=data(numAllCh+1,1,i);
    Lables_TransitionORSteady{r,i}=data(numAllCh+2,1,i);
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
%                 ExtractedFeatures = extractfield(Features{r,k},FetureSet(i));
%                 Output=[Output,ExtractedFeatures];
%             end
%             
%         end
%          
%     end
%    
%    OutputFeatures{r,k,:}=Output;
%    Output=[];
% end

% end           
Featuresarray=Features;
Featuresarray=squeeze(cell2mat(struct2cell(Featuresarray)))'; 
Featurcell=[Featurcell,Featuresarray];  

   
end
    
end