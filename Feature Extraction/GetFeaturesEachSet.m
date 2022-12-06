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
% Get features from one set of data for example extract features
% From test data
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation


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
    if i==97
        a=3;
    end
    f = GetSigFeatures(Desireddata(:,:,i),sF,FetureSet');
    Features(:,i) = f; 
    Lables(:,i)=data(numAllCh+1,1,i);
    Lables_TransitionORSteady(:,i)=data(numAllCh+2,1,i);
    Prevtag(:,i)=data(numAllCh+4,1,i);
end


      Features=squeeze(cell2mat(struct2cell(Features)))';      

end