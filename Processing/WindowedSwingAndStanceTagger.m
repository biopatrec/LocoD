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
% Devide swing and stance data and save them in seperate arrays
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation

function [AllData, SwingData,StanceData]=WindowedSwingAndStanceTagger(AllData,SwingData,StanceData,NumAllCh)
trans=0;
idxTag = NumAllCh+1;
idxTagTrans = NumAllCh+2;
idxRound = NumAllCh+3;
idxPrevTag = NumAllCh+4;
%% Tag Stance Data     
for i=1:size(StanceData,3)
   %If there is a transition in the window
    if  max(StanceData(idxTag,:,i))>10 && sum(StanceData(idxTag,:,i)==0)<100  %>10 means there was a transition and the second term to not count the windows with zero
        StanceData(idxTag,:,i)=max(StanceData(idxTag,:,i)); % That window will mark as an transition window
        StanceData(idxTagTrans,:,i)=1000;
        trans=trans+1;
        % StanceData(this.RecordingProperties.NumAllCh+1,:,i);
    else
        StanceData(idxTagTrans,:,i)=-1000;

    end

end
%% Tag Swing Data
%Tag it with transition number
for j=1:size(SwingData,3)
    
    if  max(SwingData(idxTag,:,j))>10 && sum(SwingData(idxTag,:,j)==0)<100 %>10 means there was a transition
        SwingData(idxTag,:,j)=max(SwingData(idxTag,:,j));
        SwingData(idxTagTrans,:,j)=1000;  %% if the size is grater than 2 it showes there was a transition
        trans=trans+1;
    else
        SwingData(idxTagTrans,:,j)=-1000; %% Steady state
    end

end
%% Tag All Data
for j=1:size(AllData,3)
  
    if  max(AllData(idxTag,:,j))>10 &&  sum(AllData(idxTag,:,j)==0)<100%>10 means there was a transition
        %AllData(idxTag,:,j)
        AllData(idxTag,:,j)=max(AllData(idxTag,:,j));
        AllData(idxTagTrans,:,j)=1000;  %% if the size is grater than 2 it showes there was a transition
        trans=trans+1;
    else
        AllData(idxTagTrans,:,j)=-1000; %% Steady state
       
    end
end

%% Save previouse tag for mode specific method 
for  j=1:size(SwingData,3)
    if j==1
        SwingData(idxPrevTag,:,j)=SwingData(idxTag,:,j); 
    else
        SwingData(idxPrevTag,:,j)=SwingData(idxTag,:,j-1); 
    end


end
for  j=1:size(StanceData,3)
    if j==1
        StanceData(idxPrevTag,:,j)=StanceData(idxTag,:,j); 
    else
        StanceData(idxPrevTag,:,j)=StanceData(idxTag,:,j-1); 
    end


end
for  j=1:size(AllData,3)
    if j==1
        AllData(idxPrevTag,:,j)=AllData(idxTag,:,j); 
    else
        AllData(idxPrevTag,:,j)=AllData(idxTag,:,j-1); 
    end
end

end