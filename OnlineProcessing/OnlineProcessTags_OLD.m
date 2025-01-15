close all
clear all

%This Script will take the predicted tags and true tags that was keyed in
%by the operator(True Tags) and claculate the classification accuracy in different
%movements and by taking into account that prediction can happend before or
%after the true tags.

% Load online data
load('U:\LLP\LocoD-Github\SavedData\UsableData\TF001-05102022_3_Online2.mat')
%Delet true tags that do not follow the correct rounds
GoodTagSequence = [4,3,7,3,6,3,5,3];
SamplingFreq=signalCopy.recProps.SamplingFreq;
[outSig, outPS, outTrueTags, goodMask] = DeleteBadRounds(signalCopy.signal,signalCopy.originalPressureSignal,signalCopy.tags,SamplingFreq,GoodTagSequence);
recordedRawData = outSig;
pressOriginal = outPS;
TrueTags_Unprocessed = outTrueTags;

PredictedTags=signalCopy.PredictedtagsOnline;

%Delete bad rounds for predicted tags
for j=1:length(PredictedTags)
    tagSample = PredictedTags(2, j);
    tagSample = round(tagSample); % We know tagSample is int, but let's make sure.
    if goodMask(tagSample) == 0
        % This tag falls on a "bad" signal region. Use the previous tag.
        if j~=1
            subtag= PredictedTags(1,j-1);
        elseif j==1
            subtag= GoodTagSequence(1);
        end
        PredictedTags(1,j)=subtag;
    end
end

% Add transitions for the part that has been modified due to tags that has been deleted in the previouse section...
% because it didnt followed the rounds we had in the lab
NewTagsOnline = zeros(2, length(PredictedTags));
for nr=1:length(PredictedTags)
    if nr ~= 1 && nr~=length(PredictedTags) && ...
      PredictedTags(1,nr)~=PredictedTags(1,nr+1) && ...
      LOCO.IsTagS(PredictedTags(1,nr)) && LOCO.IsTagS(PredictedTags(1,nr+1))
        % Record a transition
        Transition = LOCO.TagT(PredictedTags(1,nr), PredictedTags(1,nr+1));
        NewTagsOnline(1:2,nr)=[Transition; PredictedTags(2,nr)];
    else
        % Record a non-transition
        NewTagsOnline(1:2,nr)=PredictedTags(1:2,nr);
    end
end
PredictedTags=NewTagsOnline;

% There are situations where two identical transition-tags are predicted
% immediately after eachother. Set the latter to a non-transition-tag.
for nr=1:length(PredictedTags)
    if nr~=length(PredictedTags) && LOCO.IsTagT(PredictedTags(1,nr)) && PredictedTags(1,nr)==PredictedTags(1,nr+1)
        PredictedTags(1,nr+1)=LOCO.TagSN(PredictedTags(1,nr+1));
    end
end

% Align true tags with gait phase
TrueTags=AlignTagsWithGait(TrueTags_Unprocessed,signalCopy.GaitTransitionsOnline,SamplingFreq);

onlineaccuBefore=sum((TrueTags(1,:))==PredictedTags(1,:))/length(PredictedTags);

%% Look for transitions in the neighboring true tags
% in this case we look to see if transition happend in the previous Np gaits or in the next Nn gaits
% TODO: Explain what we are doing here.
predictonTime=0;
j=1; 
for i=1:length(TrueTags(1,:))
    if i~=1 && i~= length(TrueTags(1,:)) && i~=length(TrueTags(1,:)) -1 && i~=2 && i~= length(TrueTags(1,:)) -2 && i~=length(TrueTags(1,:)) -3 && i~=3
        if PredictedTags(1,i)>10

            %Check if predicted tag is similar to the true tag after it
            if PredictedTags(1,i)== TrueTags(1,i+1)
                TrueTags(1,i)=TrueTags(1,i+1);
                TrueTags(1,i+1)=mod(TrueTags(1,i+1),10);
                predictonTimeArray(1,j)=(PredictedTags(2,i)-TrueTags(2,i+1))/SamplingFreq; %Add the prediction time which is the time between key pressed and prediction to an array
                predictonTimeArray(2,j)=PredictedTags(1,i);
                predictonTime= predictonTime+(PredictedTags(2,i)-TrueTags(2,i+1))/SamplingFreq;
            
                j=j+1;
            %Check if predicted tag is similar to the true tag before it
            elseif   PredictedTags(1,i)== TrueTags(1,i-1)
                TrueTags(1,i)=TrueTags(1,i-1);
                TrueTags(1,i-1)=floor(TrueTags(1,i-1)/10);
                predictonTime= predictonTime+(PredictedTags(2,i)-TrueTags(2,i-1))/SamplingFreq;
                predictonTimeArray(1,j)=(PredictedTags(2,i)-TrueTags(2,i-1))/SamplingFreq; %Add the prediction time which is the time between key pressed and prediction to an array
                predictonTimeArray(2,j)=PredictedTags(1,i);

                j=j+1;
            %Check if predicted tag is similar to 2 true tags before it
            elseif PredictedTags(1,i)== TrueTags(1,i+2)
                TrueTags(1,i)=TrueTags(1,i+2);
                TrueTags(1,i+2)=mod(TrueTags(1,i+2),10);
                TrueTags(1,i+1)=mod(TrueTags(1,i+2),10);
                predictonTimeArray(1,j)=(PredictedTags(2,i)-TrueTags(2,i+2))/SamplingFreq; %Add the prediction time which is the time between key pressed and prediction to an array
                predictonTimeArray(2,j)=PredictedTags(1,i);
                predictonTime= predictonTime+(PredictedTags(2,i)-TrueTags(2,i+2))/SamplingFreq;
                j=j+1;
            %Check if predicted tag is similar to 2 true tags after it
            elseif  PredictedTags(1,i)== TrueTags(1,i-2)
                TrueTags(1,i)=TrueTags(1,i-2);
                TrueTags(1,i-2)=floor(TrueTags(1,i-2)/10);
                TrueTags(1,i-1)=floor(TrueTags(1,i-2)/10);
                predictonTime= predictonTime+(PredictedTags(2,i)-TrueTags(2,i-2))/SamplingFreq;
                predictonTimeArray(1,j)=(PredictedTags(2,i)-TrueTags(2,i-2))/SamplingFreq; %Add the prediction time which is the time between key pressed and prediction to an array
                predictonTimeArray(2,j)=PredictedTags(1,i);
                j=j+1;
             %Check if predicted tag is similar to 3 true tags after it
            elseif  PredictedTags(1,i)== TrueTags(1,i-3)
                TrueTags(1,i)=TrueTags(1,i-3);
                TrueTags(1,i-3)=floor(TrueTags(1,i-3)/10);
                TrueTags(1,i-2)=floor(TrueTags(1,i-3)/10);
                TrueTags(1,i-1)=floor(TrueTags(1,i-3)/10);
                predictonTime= predictonTime+(PredictedTags(2,i)-TrueTags(2,i-3))/SamplingFreq;
                predictonTimeArray(1,j)=(PredictedTags(2,i)-TrueTags(2,i-3))/SamplingFreq; %Add the prediction time which is the time between key pressed and prediction to an array
                predictonTimeArray(2,j)=PredictedTags(1,i);
                j=j+1;
            %Just for claculating the delay
            elseif PredictedTags(1,i)== TrueTags(1,i)
                 predictonTimeArray(1,j)=0; %Add the prediction time which is the time between key pressed and prediction to an array
                predictonTimeArray(2,j)=PredictedTags(1,i);
                j=j+1;
            end
        end
    end
end

%In order to plot zero the true predictions
ZTrueLabelsOnline=TrueTags;
ZPredictedtagsOnline=PredictedTags;
for i=1:length(TrueTags(1,:))
    if PredictedTags(1,i)==TrueTags(1,i)
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

% stairs(TrueTags(2,:),TrueTags(1,:));
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
stem(PredictedTags(2,:),PredictedTags(1,:)); 
hold on
stairs(TrueTags(2,:),TrueTags(1,:));


legend("Predicted","True");


%% Calculate Accuracy
onlineaccu=sum((TrueTags(1,:)==PredictedTags(1,:) & TrueTags(1,:)~=0))/sum(TrueTags(1,:)~=0)

% Calculate Teansition and Steady State accuracy
ss=1;
tr=1;

for j=1:length(TrueTags)
    if TrueTags(1,j)>10 %Transition
        TrueLabTransition(tr)=TrueTags(1,j);
        PredictedLabelTransition(1,tr)=PredictedTags(1,j);
        tr=tr+1;

    elseif TrueTags(1,j)~=0
        TrueLabSS(1,ss)=TrueTags(1,j);
        PredictedLabelSS(1,ss)=PredictedTags(1,j);
        ss=ss+1;

    end
end

onlineaccuTR=sum(TrueLabTransition==PredictedLabelTransition) / length(PredictedLabelTransition)
onlineaccuSS=sum(TrueLabSS==PredictedLabelSS )/ length(PredictedLabelSS)
meanPredictonTime=mean(predictonTimeArray(1,:))
predictonTime= predictonTime/length(predictonTimeArray(1,:))
%Calculate prediction time for each movemnt
time_34=sum(predictonTimeArray(1,predictonTimeArray(2,:)==34))/sum(predictonTimeArray(2,:)==34)
time_35=sum(predictonTimeArray(1,predictonTimeArray(2,:)==35))/sum(predictonTimeArray(2,:)==35)
time_36=sum(predictonTimeArray(1,predictonTimeArray(2,:)==36))/sum(predictonTimeArray(2,:)==36)
time_37=sum(predictonTimeArray(1,predictonTimeArray(2,:)==37))/sum(predictonTimeArray(2,:)==37)
time_73=sum(predictonTimeArray(1,predictonTimeArray(2,:)==73))/sum(predictonTimeArray(2,:)==73)
time_63=sum(predictonTimeArray(1,predictonTimeArray(2,:)==63))/sum(predictonTimeArray(2,:)==63)
time_53=sum(predictonTimeArray(1,predictonTimeArray(2,:)==53))/sum(predictonTimeArray(2,:)==53)
time_43=sum(predictonTimeArray(1,predictonTimeArray(2,:)==43))/sum(predictonTimeArray(2,:)==43)

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
