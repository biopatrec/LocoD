%Window data on swing and stance
function [AllTags, SwingTags, StanceTags] = SwingStanceDeviderOnline(PredictedLabelAll,GaitTransition,TagArray,BeforeEvent,recProps,AfterEvent,Inctime,windowlength,Windowingmethod)

SwingTags=[];
StanceTags=[];
nSw=1;
nSt=1;
nAll=1;
sf=recProps.SamplingFreq;

for i=1:length(GaitTransition)- 2
    %%AS soon as the pressure threshold turns from swing to
    %%stance we consider it as the start of stance and each
    %%window it will 200ms before stance and 100ms after stance
    %%The same will be for swing
    GaitTransitionIndex=GaitTransition(2,i);
    if i~=1 && GaitTransition(1,i)==98 && GaitTransitionIndex<TagArray(2,end-1)  %swing to stance HC

        if Windowingmethod=="On gait phase(before and after)"
            datalength=AfterEvent+BeforeEvent;
            numwindowbefore= floor(((datalength-windowlength)/Inctime)+1);
            data=TagArray(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            for k=1:length(data(2,:))
                for j=1:length(PredictedLabelAll(2,:))
                    if data(2,k)==PredictedLabelAll(2,j)
                        c(2)=data(2,k);
                        return
                    end
                end
                if k==length(data(2,:)) && j==length(PredictedLabelAll(2,:)) && data(2,k)~=PredictedLabelAll(2,j)
                    c(2)=0;
                end
            end
            %data=TagArray(GaitTransitionIndex);
            for w=1:numwindowbefore
                [a,~]=max(data(1,:));
                c(1)=a;
                %c(2)=data(2,b);
                SwingTags(:,nSt)=c(:);
                AllTags(:,nAll)=c(:);
                nSt=nSt+1;
                nAll=nAll+1;
            end
            
        end
    elseif i~=1 && GaitTransition(1,i)==89 && GaitTransitionIndex<TagArray(2,end-1)   %stance to swing TO

        if Windowingmethod=="On gait phase(before and after)"
            datalength=AfterEvent+BeforeEvent;
            numwindowbefore= floor(((datalength-windowlength)/Inctime)+1);
            data=TagArray(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            for k=1:length(data(2,:))
                for j=1:length(PredictedLabelAll(2,:))
                    if data(2,i)==PredictedLabelAll(2,j)
                        c(2)=data(2,k);
                        return
                    end
                end
                if k==length(data(2,:)) && j==length(PredictedLabelAll(2,:)) && data(2,k)~=PredictedLabelAll(2,j)
                    c(2)=0;
                end
            end
            for w=1:numwindowbefore
                [a,~]=max(data(1,:));
                c(1)=a;
                %c(2)=data(2,b);
                SwingTags(:,nSw)=c(:);
                AllTags(:,nAll)=c(:);
                nSw=nSw+1;
                nAll=nAll+1;
            end
        end
    end
end
%Remove Zeros

AllTags=AllTags(:,AllTags(2,:)~=0);
end