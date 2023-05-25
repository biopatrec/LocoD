%Devide swing and stance data and save them in seperate arrays
function [AllData, SwingData,StanceData]=WindowedSwingAndStanceTagger(AllData,SwingData,StanceData,NumAllCh)
trans=0;
idxTag = NumAllCh+1;
idxTagTrans = NumAllCh+2;
idxRound = NumAllCh+3;
idxPrevTag = NumAllCh+4;
            
for i=1:size(StanceData,3)
    %uniqueOnSt=unique(StanceData(idxTag,:,i),'stable');
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
    %UniqueOnSw= unique(SwingData(idxTag,:,j),'stable');
    if  max(SwingData(idxTag,:,j))>10 && sum(SwingData(idxTag,:,j)==0)<100 %>10 means there was a transition
        SwingData(idxTag,:,j)=max(SwingData(idxTag,:,j));
        SwingData(idxTagTrans,:,j)=1000;  %% if the size is grater than 2 it showes there was a transition
        trans=trans+1;
    else
        SwingData(idxTagTrans,:,j)=-1000; %% Steady state
    end

end
for j=1:size(AllData,3)
   % UniqueOnSw= unique(AllData(idxTag,:,j),'stable');
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