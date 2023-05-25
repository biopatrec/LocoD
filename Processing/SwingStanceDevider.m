%Window data on swing and stance
function [AllData, SwingData, StanceData] = SwingStanceDevider(GaitTransition,signalPlusTags,BeforeEvent,recProps,AfterEvent,Inctime,windowlength,Windowingmethod)

SwingData=[];
StanceData=[];
nSw=1;
nSt=1;
nAll=1;
sf=recProps.SamplingFreq;
numCh=recProps.NumAllCh;
idxTag=numCh+1;

for i=1:length(GaitTransition)- 2
    %%AS soon as the pressure threshold turns from swing to
    %%stance we consider it as the start of stance and each
    %%window it will 200ms before stance and 100ms after stance
    %%The same will be for swing
    GaitTransitionIndex=GaitTransition(2,i);
    if i~=1 && GaitTransition(1,i)==98  %swing to stance HC

        if Windowingmethod=="On gait phase(before and after)"
            datalength=AfterEvent+BeforeEvent;
            numwindowbefore= floor(((datalength-windowlength)/Inctime)+1);
            data=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            %             if max(data(idxTag,:))>10   %If there is a transiton all windows count as transition
            %                 data(idxTag,:)=max(data(idxTag,:));
            %             end
            data(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);
            for w=1:numwindowbefore
                StanceData(:,:,nSt)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);

                nSt=nSt+1;
                nAll=nAll+1;
            end
        elseif Windowingmethod=="Window before and window after"

            numwindowbefore= floor(((BeforeEvent-windowlength)/Inctime)+1);
            databefore=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex-1);
            %             if max(databefore(idxTag,:))>10   %If there is a transiton all windows count as transition
            %                 databefore(idxTag,:)=max(databefore(idxTag,:));
            %             end
            databefore(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);
            for w=1:numwindowbefore
                StanceData(:,:,nSt)= databefore(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= databefore(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                nSt=nSt+1;
                nAll=nAll+1;

            end

            numwindowafter= floor(((AfterEvent-windowlength)/Inctime)+1);
            dataafter=signalPlusTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            %             if max(dataafter(idxTag,:))>10   %If there is a transiton all windows count as transition
            %                 dataafter(idxTag,:)=max(dataafter(idxTag,:));
            %             end
            dataafter(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);
            for w=1:numwindowafter
                StanceData(:,:,nSt)= dataafter(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= dataafter(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                nSt=nSt+1;
                nAll=nAll+1;

            end


        end
    elseif i~=1 && GaitTransition(1,i)==89  %stance to swing TO

        if Windowingmethod=="On gait phase(before and after)"
            datalength=AfterEvent+BeforeEvent;
            numwindowbefore= floor(((datalength-windowlength)/Inctime)+1);
            data=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            %             if max(data(idxTag,:))>10   %If there is a transiton all windows count as transition
            %                 data(idxTag,:)=max(data(idxTag,:));
            %             end
            data(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);

            for w=1:numwindowbefore
                SwingData(:,:,nSw)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                nSw=nSw+1;
                nAll=nAll+1;

            end
        elseif Windowingmethod=="Window before and window after"
            numwindowbefore= floor(((BeforeEvent-windowlength)/Inctime)+1);
            databefore=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex-1);
            %             if max(databefore(idxTag,:))>10   %If there is a transiton all windows count as transition
            %                 databefore(idxTag,:)=max(databefore(idxTag,:));
            %             end
            databefore(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);

            for v=1:numwindowbefore
                SwingData(:,:,nSw)= databefore(:,(v-1)*Inctime*sf+1:windowlength*sf+(v-1)*Inctime*sf);
                AllData(:,:,nAll)= databefore(:,(v-1)*Inctime*sf+1:windowlength*sf+(v-1)*Inctime*sf);
                nSw=nSw+1;
                nAll=nAll+1;

            end

            numwindowafter= floor(((AfterEvent-windowlength)/Inctime)+1);
            dataafter=signalPlusTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            %             if max(dataafter(idxTag,:))>10   %If there is a transiton all windows count as transition
            %                 dataafter(idxTag,:)=max(dataafter(idxTag,:));
            %             end
            dataafter(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);

            for v=1:numwindowafter
                SwingData(:,:,nSw)= dataafter(:,(v-1)*Inctime*sf+1:windowlength*sf+(v-1)*Inctime*sf);
                AllData(:,:,nAll)= dataafter(:,(v-1)*Inctime*sf+1:windowlength*sf+(v-1)*Inctime*sf);
                nSw=nSw+1;
                nAll=nAll+1;

            end
        end
    end
end
end