close all
clear all
% Load online data
load('U:\LLP\LocoD-Github\SavedData\UsableData\TF008-16112022_1_Online_1.mat')
%Delet true tags that do not follow the correct rounds
GoodTagSequence = [4,3,7,3,6,3,5,3];
SamplingFreq=signalCopy.recProps.SamplingFreq;
[outSig, outPS, outTags,Mask] = DeleteBadRounds(signalCopy.signal,signalCopy.originalPressureSignal,signalCopy.tags,SamplingFreq,GoodTagSequence);
recordedRawData = outSig;
pressOriginal = outPS;
tags = outTags;

PredictedtagsOnline=signalCopy.PredictedtagsOnline;
%Delete bad rounds for predicted tags
for i=1:length(Mask)
    for j=1:length(PredictedtagsOnline)
        if Mask(i)==0 && i==PredictedtagsOnline(2,j)
            if j~=1
                subtag= PredictedtagsOnline(1,j-1);
            elseif j==1
                subtag= 4; %First one in the good round
            end
            PredictedtagsOnline(1,j)=subtag;
        end
    end
end
%% Add transitions for the part that has been modified due to bad rounds
nr=1;
tran=1;
while nr<=length(PredictedtagsOnline)
    if nr~=length(PredictedtagsOnline) && PredictedtagsOnline(1,nr)~=PredictedtagsOnline(1,nr+1) && nr~=1 && PredictedtagsOnline(1,nr)<10 && PredictedtagsOnline(1,nr+1)<10

        Transition=PredictedtagsOnline(1,nr)*10+PredictedtagsOnline(1,nr+1);
        TagArrays(1,nr)=Transition;
        TagArrays(2,nr)=PredictedtagsOnline(2,nr);

    else
        TagArrays(1,nr)=PredictedtagsOnline(1,nr);
        TagArrays(2,nr)=PredictedtagsOnline(2,nr);


    end
    nr=nr+1;

end

PredictedtagsOnline=TagArrays;

%Remove if there is two transition predicted after each other

for k=1:length(PredictedtagsOnline)
    if k~=length(PredictedtagsOnline) && PredictedtagsOnline(1,k)>10 && PredictedtagsOnline(1,k)==PredictedtagsOnline(1,k+1)
        PredictedtagsOnline(1,k+1)=mod(PredictedtagsOnline(1,k+1),10);
    end
end

TrueLabelsOnline=ProcessTags(tags,signalCopy.GaitTransitionsOnline,SamplingFreq);
onlineaccuBefore=sum((TrueLabelsOnline(1,:))==PredictedtagsOnline(1,:))/length(PredictedtagsOnline)

predictonTime=0;
%% Look for transitions in the neighbor predictions in this case we look to see if transition happend in the prviose 2 gaits or in the next 2 gaits
for i=1:length(TrueLabelsOnline(1,:))
    if i~=1 && i~= length(TrueLabelsOnline(1,:)) && i~=length(TrueLabelsOnline(1,:)) -1 && i~=2 && i~= length(TrueLabelsOnline(1,:)) -2 && i~=length(TrueLabelsOnline(1,:)) -3 && i~=3
        if PredictedtagsOnline(1,i)>10


            if PredictedtagsOnline(1,i)== TrueLabelsOnline(1,i+1)
                TrueLabelsOnline(1,i)=TrueLabelsOnline(1,i+1);
                TrueLabelsOnline(1,i+1)=mod(TrueLabelsOnline(1,i+1),10);
                predictonTime= predictonTime+(PredictedtagsOnline(2,i)-TrueLabelsOnline(2,i+1))/SamplingFreq;

            elseif   PredictedtagsOnline(1,i)== TrueLabelsOnline(1,i-1)
                TrueLabelsOnline(1,i)=TrueLabelsOnline(1,i-1);
                TrueLabelsOnline(1,i-1)=floor(TrueLabelsOnline(1,i-1)/10);
                predictonTime= predictonTime+(PredictedtagsOnline(2,i)-TrueLabelsOnline(2,i-1))/SamplingFreq;

            elseif PredictedtagsOnline(1,i)== TrueLabelsOnline(1,i+2)
                TrueLabelsOnline(1,i)=TrueLabelsOnline(1,i+2);
                TrueLabelsOnline(1,i+2)=mod(TrueLabelsOnline(1,i+2),10);
                TrueLabelsOnline(1,i+1)=mod(TrueLabelsOnline(1,i+2),10);
                predictonTime= predictonTime+(PredictedtagsOnline(2,i)-TrueLabelsOnline(2,i+2))/SamplingFreq;

            elseif  PredictedtagsOnline(1,i)== TrueLabelsOnline(1,i-2)
                TrueLabelsOnline(1,i)=TrueLabelsOnline(1,i-2);
                TrueLabelsOnline(1,i-2)=floor(TrueLabelsOnline(1,i-2)/10);
                TrueLabelsOnline(1,i-1)=floor(TrueLabelsOnline(1,i-2)/10);
                predictonTime= predictonTime+(PredictedtagsOnline(2,i)-TrueLabelsOnline(2,i-2))/SamplingFreq;
            elseif  PredictedtagsOnline(1,i)== TrueLabelsOnline(1,i-3)
                TrueLabelsOnline(1,i)=TrueLabelsOnline(1,i-3);
                TrueLabelsOnline(1,i-3)=floor(TrueLabelsOnline(1,i-3)/10);
                TrueLabelsOnline(1,i-2)=floor(TrueLabelsOnline(1,i-3)/10);
                TrueLabelsOnline(1,i-1)=floor(TrueLabelsOnline(1,i-3)/10);
                predictonTime= predictonTime+(PredictedtagsOnline(2,i)-TrueLabelsOnline(2,i-3))/SamplingFreq;
            elseif  PredictedtagsOnline(1,i)== TrueLabelsOnline(1,i-4)
%                 TrueLabelsOnline(1,i)=TrueLabelsOnline(1,i-4);
%                 TrueLabelsOnline(1,i-4)=floor(TrueLabelsOnline(1,i-4)/10);
%                 TrueLabelsOnline(1,i-3)=floor(TrueLabelsOnline(1,i-4)/10);
%                 TrueLabelsOnline(1,i-2)=floor(TrueLabelsOnline(1,i-4)/10);
%                 TrueLabelsOnline(1,i-1)=floor(TrueLabelsOnline(1,i-4)/10);
%                 predictonTime= predictonTime+(PredictedtagsOnline(2,i)-TrueLabelsOnline(2,i-4))/SamplingFreq;


            end
        end
    end
end

%In order to plot zero the true predictions
ZTrueLabelsOnline=TrueLabelsOnline;
ZPredictedtagsOnline=PredictedtagsOnline;
for i=1:length(TrueLabelsOnline(1,:))
    if PredictedtagsOnline(1,i)==TrueLabelsOnline(1,i)
        ZTrueLabelsOnline(1,i)=0;
        ZPredictedtagsOnline(1,i)=0;
    end
end

figure
%Plot predicetd tags
stem(ZPredictedtagsOnline(2,:),ZPredictedtagsOnline(1,:));
hold on;
%Plot true tags
stem(ZTrueLabelsOnline(2,:),ZTrueLabelsOnline(1,:));
hold on;
%Plot Gait
stairs(signalCopy.GaitTransitionsOnline(2,:),signalCopy.GaitTransitionsOnline(1,:));
hold on;

% stairs(TrueLabelsOnline(2,:),TrueLabelsOnline(1,:));
% hold on
% stem(PredictedtagsOnline(2,:),PredictedtagsOnline(1,:));
legend("Predicted","True","Gait")%,"True","Predicted");

figure
subplot(3,1,1)
%Plot predicetd tags
stem(ZPredictedtagsOnline(2,:),ZPredictedtagsOnline(1,:));
hold on;
%Plot true tags
stem(ZTrueLabelsOnline(2,:),ZTrueLabelsOnline(1,:));
legend("Predicted","True");
subplot(3,1,3)
stairs(signalCopy.GaitTransitionsOnline(2,:),signalCopy.GaitTransitionsOnline(1,:));
subplot(3,1,2)
stem(PredictedtagsOnline(2,:),PredictedtagsOnline(1,:)); 
hold on
stairs(TrueLabelsOnline(2,:),TrueLabelsOnline(1,:));


legend("Predicted","True");


%% Calculate Accuracy
onlineaccu=sum((TrueLabelsOnline(1,:)==PredictedtagsOnline(1,:) & TrueLabelsOnline(1,:)~=0))/sum(TrueLabelsOnline(1,:)~=0)

% Calculate Teansition and Steady State accuracy
ss=1;
tr=1;

for j=1:length(TrueLabelsOnline)
    if TrueLabelsOnline(1,j)>10 %Transition
        TrueLabTransition(tr)=TrueLabelsOnline(1,j);
        PredictedLabelTransition(1,tr)=PredictedtagsOnline(1,j);
        tr=tr+1;

    elseif TrueLabelsOnline(1,j)~=0
        TrueLabSS(1,ss)=TrueLabelsOnline(1,j);
        PredictedLabelSS(1,ss)=PredictedtagsOnline(1,j);
        ss=ss+1;

    end
end

onlineaccuTR=sum(TrueLabTransition==PredictedLabelTransition) / length(PredictedLabelTransition)
onlineaccuSS=sum(TrueLabSS==PredictedLabelSS )/ length(PredictedLabelSS)
predictonTime=predictonTime/length(PredictedLabelTransition)


%% Calculate accuracy for each movement in transition
onlineaccuTR_34 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==34) / sum(TrueLabTransition==34);
onlineaccuTR_35 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==35) / sum(TrueLabTransition==35);
onlineaccuTR_36 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==36) / sum(TrueLabTransition==36);
onlineaccuTR_37 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==37) / sum(TrueLabTransition==37);
onlineaccuTR_43 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==43) / sum(TrueLabTransition==43);
onlineaccuTR_53 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==53) / sum(TrueLabTransition==53);
onlineaccuTR_63 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==63) / sum(TrueLabTransition==63);
onlineaccuTR_73 = sum(TrueLabTransition==PredictedLabelTransition & TrueLabTransition==73) / sum(TrueLabTransition==73);

%Calculate accuracy for each movemnt in Steady
onlineaccuSS_3 = sum(TrueLabSS==PredictedLabelSS & TrueLabSS==3) / sum(TrueLabSS==3);
onlineaccuSS_4 = sum(TrueLabSS==PredictedLabelSS & TrueLabSS==4) / sum(TrueLabSS==4);
onlineaccuSS_5 = sum(TrueLabSS==PredictedLabelSS & TrueLabSS==5) / sum(TrueLabSS==5);
onlineaccuSS_6 = sum(TrueLabSS==PredictedLabelSS & TrueLabSS==6) / sum(TrueLabSS==6);
onlineaccuSS_7 = sum(TrueLabSS==PredictedLabelSS & TrueLabSS==7) / sum(TrueLabSS==7);

onlinaccuSS_all=[onlineaccuSS_3 ,onlineaccuSS_4,onlineaccuSS_5,onlineaccuSS_6,onlineaccuSS_7]'*100;
onlineaccuTr_all=[onlineaccuTR_34,onlineaccuTR_35 ,onlineaccuTR_36 ,onlineaccuTR_37 ,onlineaccuTR_43,onlineaccuTR_53 ,onlineaccuTR_63, onlineaccuTR_73 ]'*100;
