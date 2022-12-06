% ---------------------------- Copyright Notice ---------------------------
% This file is part of LocoD © which is open and free software under
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for
% the full license governing this code and copyrights.
%
% LocoD was initially developed by Bahareh Ahkami at
% Center for Bionics and Pain research and Chalmers University of Technology.
% All authors’ contributions must be kept
% acknowledged below in the section "Updates % Contributors".
%
% Would you like to contribute to science and sum efforts to improve
% amputees’ quality of life? Join this project! or, send your comments to:
% ahkami@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file
% linked to LocoD. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).

% acknowledge contributions here and in the project web page (optional).
% ------------------- Function Description ------------------
%Get features from each window of data
% 
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation

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


end