%Devide steady state and transition by tagging them 1000 and -1000

function  [SwingDataTransition,SwingDataSteady,StanceDataTransition,StanceDataSteady,AllDataSteady,AllDataTransition]=TransitionSteadyDivider(AllData,SwingData, StanceData,NumAllCh)

idxTag = NumAllCh+1;
idxTagTrans = NumAllCh+2;
idxRound = NumAllCh+3;
idxPrevTag = NumAllCh+4;

j=1;
k=1;
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