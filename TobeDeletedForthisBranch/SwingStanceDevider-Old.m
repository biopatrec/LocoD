function [AllData, SwingData, StanceData] = SwingStanceDevider(GaitTransition,eventDataWithTags,BeforeEvent,sf,AfterEvent,Inctime,windowlength,Windowingmethod)

SwingData=[];
StanceData=[];
sw=0;
st=0;
a=0;

for i=1:length(GaitTransition)- 2
    %%AS soon as the pressure threshold turns from swing to
    %%stance we consider it as the start of stance and each
    %%window it will 200ms before stance and 100ms after stance
    %%The same will be for swing
    GaitTransitionIndex=GaitTransition(2,i);
    if i~=1 && GaitTransition(1,i)==98  %swing to stance
        %st=st+1;
        %a=a+1;
        if Windowingmethod=="On gait phase(before and after)"
            StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
        elseif Windowingmethod=="Window before and window after"

            numwindow= ((BeforeEvent-windowlength)/Inctime)+1;
            for w=1:numwindow
                StanceData(:,:,w)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
                AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
                a=a+1;
            end
            StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            a=a+1;
            st=st+1;
            StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            %         elseif Windowingmethod=="1 window before 1
            % elseif Windowingmethod=="1 window before 1 window after"
            %             StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            %             AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            %             a=a+1;
            %             st=st+1;
            %             StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            %             AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            % %         elseif Windowingmethod=="1 window before 1 window after with INC."
            %
            %         elseif Windowingmethod=="2 windows before 2 windows after"
            %             StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex-2*BeforeEvent*sf+1:GaitTransitionIndex-BeforeEvent*sf);
            %             AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-2*BeforeEvent*sf+1:GaitTransitionIndex-BeforeEvent*sf);
            %             a=a+1;
            %             st=st+1;
            %              StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            %             AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            %             a=a+1;
            %             st=st+1;
            %             StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            %             AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            %             a=a+1;
            %             st=st+1;
            %             StanceData(:,:,st)= eventDataWithTags(:,GaitTransitionIndex+AfterEvent*sf:GaitTransitionIndex+2*AfterEvent*sf-1);
            %             AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex+AfterEvent*sf:GaitTransitionIndex+2*AfterEvent*sf-1);
            %
        end
    elseif i~=1 && GaitTransition(1,i)==89  %stance to swing
        sw=sw+1;
        a=a+1;
        if Windowingmethod=="On gait phase(before and after)"
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf:GaitTransitionIndex+AfterEvent*sf-1);

        elseif Windowingmethod=="1 window before 1 window after"
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            sw=sw+1;
            a=a+1;
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
        elseif Windowingmethod=="2 windows before 2 windows after"
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex-2*BeforeEvent*sf+1:GaitTransitionIndex-BeforeEvent*sf);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-2*BeforeEvent*sf+1:GaitTransitionIndex-BeforeEvent*sf);
            a=a+1;
            sw=sw+1;
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex-BeforeEvent*sf+1:GaitTransitionIndex);
            a=a+1;
            sw=sw+1;
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex:GaitTransitionIndex+AfterEvent*sf-1);
            a=a+1;
            sw=sw+1;
            SwingData(:,:,sw)= eventDataWithTags(:,GaitTransitionIndex+AfterEvent*sf:GaitTransitionIndex+2*AfterEvent*sf-1);
            AllData(:,:,a)= eventDataWithTags(:,GaitTransitionIndex+AfterEvent*sf:GaitTransitionIndex+2*AfterEvent*sf-1);

        end
    end
end
end