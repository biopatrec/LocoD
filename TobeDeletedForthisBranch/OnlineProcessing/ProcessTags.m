function ProcessedTags=ProcessTags(tags,gaitTrans,fs)
% Get channel indices

numTag = length(tags);
tags(2,:)=floor(tags(2,:) * fs) + 1;

for t=1:length(tags)
    [~,closestGTIndex] = min(abs(tags(2,t) - gaitTrans(2,:)));
    tags(2,t)=gaitTrans(2,closestGTIndex);
end

%Remove before First tag
% for nr=1:numTag
%     currentTag = tags(1,nr);
%     currentTagTime = tags(2,nr);
%     currentTagSample = tags(2,numTag);
% end
% How many transitions is there between tag 1 and  tag 2
%Pad tag array

for nr=1:numTag
    if nr~=numTag
        s1=find(gaitTrans(2,:)==tags(2,nr));
        s2=find(gaitTrans(2,:)==tags(2,nr+1));
        padnum=s2-s1;
        if nr==1
            TagArray(1,1:s1-1)=tags(1,nr)*ones(1,s1-1);
            TagArray(2,1:s1-1)=gaitTrans(2,1:s1-1);
        end
        TagArray(1,s1:s2-1)=tags(1,nr)*ones(1,padnum);
        TagArray(2,s1:s2-1)=gaitTrans(2,s1:s2-1);
    elseif nr==numTag
        s1=find(gaitTrans(2,:)==tags(2,nr));
        s2=length(gaitTrans);
        %padnum=s2-s1;
        TagArray(1,s1:s2)=tags(1,nr);
        TagArray(2,s1:s2)=gaitTrans(2,s1:s2);
    end
end
tran=1;
nr=1;
while nr<=length(TagArray)
    if nr~=length(TagArray) && TagArray(1,nr)~=TagArray(1,nr+1) && nr~=1

        Transition=TagArray(1,nr)*10+TagArray(1,nr+1);
        if Transition == 36 ||   Transition==63 %Walk to SA or SA to W happend in TO or Swing  89
            if gaitTrans(1,nr)==89
                TagArrays(1,tran)=Transition;
                TagArrays(2,tran)=TagArray(2,nr);

                tran=tran+1;
            else
                TagArrays(1,tran)=TagArray(1,nr);
                TagArrays(2,tran)=TagArray(2,nr);
                TagArrays(1,tran+1)=Transition;
                TagArrays(2,tran+1)=TagArray(2,nr);
                tran=tran+2;
                nr=nr+1;


            end
        elseif Transition==53  || Transition==73  %Ramp decent to walk or SD to walk Happens in HC or Stance 98
            if gaitTrans(1,nr)==98
                TagArrays(1,tran)=Transition;
                TagArrays(2,tran)=TagArray(2,nr);
                tran=tran+1;
            else
                TagArrays(2,tran)=TagArray(2,nr);
                TagArrays(1,tran)=TagArray(1,nr);
                TagArrays(1,tran+1)=Transition;
                TagArrays(2,tran+1)=TagArray(2,nr);
                tran=tran+2;
                nr=nr+1;


            end
        else
            TagArrays(1,tran)=Transition;
            TagArrays(2,tran)=TagArray(2,nr);
            tran=tran+1;
        end

    else
        TagArrays(1,tran)=TagArray(1,nr);
        TagArrays(2,tran)=TagArray(2,nr);
        tran=tran+1;
    end
    nr=nr+1;
end

%Voila!

%Add tag to each window
%[Windowedsignal,~,~]=SwingStanceDeviderOnline(PredictedLabelAll,gaitTrans,TagArrays,BeforeEvent,rp,AfterEvent,IncTime,WindowLength,WindowingMethod);

% for j=1:size(Windowedsignal,2)
%     % UniqueOnSw= unique(signal(idxTag,:,j),'stable');
%     if  max(Windowedsignal(:,j))>10 &&  sum(Windowedsignal(:,j)==0)<100%>10 means there was a transition
%         %signal(idxTag,:,j)
%         Windowedsignal(:,j)=max(Windowedsignal(:,j));
% %        trans=trans+1;
%     end
%
% end
%ProcessedTags=Windowedsignal;
ProcessedTags=TagArrays;
end

