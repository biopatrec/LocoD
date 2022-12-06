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
%Window data on swing and stance
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation


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
        %Windowing happends on each gait phase from before to after
        if Windowingmethod=="On gait phase(before and after)"
            datalength=AfterEvent+BeforeEvent;
            numwindowbefore= floor(((datalength-windowlength)/Inctime)+1);
            data=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            data(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);
            for w=1:numwindowbefore
                StanceData(:,:,nSt)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);

                nSt=nSt+1;
                nAll=nAll+1;
            end
        elseif Windowingmethod=="Window before and window after"
            % Windowing happends on each gait phase but the data from before
            % and from after are seperate
            numwindowbefore= floor(((BeforeEvent-windowlength)/Inctime)+1);  %find number of windows can fit in the data 
            databefore=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex-1); %extract data
            databefore(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex); %The whole extracted data will have the same tag
            for w=1:numwindowbefore  % Extract windows 
                StanceData(:,:,nSt)= databefore(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= databefore(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                nSt=nSt+1;
                nAll=nAll+1;

            end

            numwindowafter= floor(((AfterEvent-windowlength)/Inctime)+1);
            dataafter=signalPlusTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            dataafter(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);
            for w=1:numwindowafter
                StanceData(:,:,nSt)= dataafter(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= dataafter(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                nSt=nSt+1;
                nAll=nAll+1;

            end


        end
    elseif i~=1 && GaitTransition(1,i)==89  %stance to swing TO
        %Windowing happends on each gait phase from before to after
        if Windowingmethod=="On gait phase(before and after)"
            datalength=AfterEvent+BeforeEvent;
            numwindowbefore= floor(((datalength-windowlength)/Inctime)+1);
            data=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);

            data(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);

            for w=1:numwindowbefore
                SwingData(:,:,nSw)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                AllData(:,:,nAll)= data(:,(w-1)*Inctime*sf+1:windowlength*sf+(w-1)*Inctime*sf);
                nSw=nSw+1;
                nAll=nAll+1;

            end
            % Windowing happends on each gait phase but the data from before
            % and from after are seperate
        elseif Windowingmethod=="Window before and window after"
            numwindowbefore= floor(((BeforeEvent-windowlength)/Inctime)+1);
            databefore=signalPlusTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex-1);
            databefore(idxTag,:)=signalPlusTags(idxTag,GaitTransitionIndex);

            for v=1:numwindowbefore
                SwingData(:,:,nSw)= databefore(:,(v-1)*Inctime*sf+1:windowlength*sf+(v-1)*Inctime*sf);
                AllData(:,:,nAll)= databefore(:,(v-1)*Inctime*sf+1:windowlength*sf+(v-1)*Inctime*sf);
                nSw=nSw+1;
                nAll=nAll+1;

            end

            numwindowafter= floor(((AfterEvent-windowlength)/Inctime)+1);
            dataafter=signalPlusTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
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