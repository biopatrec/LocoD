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
% Devide steady state and transition by tagging them 1000 and -1000
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation


%1000 represent transition and -1000 represent steady

function  [SwingDataTransition,SwingDataSteady,StanceDataTransition,StanceDataSteady,AllDataSteady,AllDataTransition]=TransitionSteadyDivider(AllData,SwingData, StanceData,NumAllCh)

idxTag = NumAllCh+1;
idxTagTrans = NumAllCh+2;
idxRound = NumAllCh+3;
idxPrevTag = NumAllCh+4;

j=1;
k=1;

%Devid steady and transition in swing
numWindowSwing=size(SwingData,3);
for i=1:numWindowSwing
    if SwingData(idxTagTrans,:,i)==1000
        %Transition
        SwingDataTransition(:,:,j)=SwingData(:,:,i);
        j=j+1;

    else
        % Steady
        SwingDataSteady(:,:,k)=SwingData(:,:,i);
        k=k+1;
    end
end
n=1;
m=1;
numWindowStance=size(StanceData,3);

%Devid steady and transition in stance
for i=1:numWindowStance
    if StanceData(idxTagTrans,:,i)==1000
        %Transition
        StanceDataTransition(:,:,n)=StanceData(:,:,i);
        n=n+1;
    else
        % Steady
        StanceDataSteady(:,:,m)=StanceData(:,:,i);

        m=m+1;
    end
end
z=1;
y=1;
numWindowall=size(AllData,3);
%Devid steady and transition in all the data
for i=1:numWindowStance
    if AllData(idxTagTrans,:,i)==1000
        %Transition
        AllDataTransition(:,:,z)=AllData(:,:,i);
        z=z+1;
    else
        % Steady
        AllDataSteady(:,:,y)=AllData(:,:,i);  
        y=y+1;
    end
end
end