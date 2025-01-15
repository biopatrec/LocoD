% Align tags with gait phase
function ProcessedTags=AlignTagsWithGait(labels,gaitTrans,fs)

numLabel = length(labels);
numGaitTrans = length(gaitTrans);
gaitTransTimes = gaitTrans(2,:);

% Convert to sample count
labels(2,:)=floor(labels(2,:) * fs) + 1;

% Each label is aligned to a gait transition closest in time
for t=1:numLabel
    [~,idxClosestGaitTrans] = min(abs(labels(2,t) - gaitTransTimes));
    labels(2,t)=gaitTrans(2,idxClosestGaitTrans);
end

% Figure out a matrix that indicates the label at occurence time
%   of each gait transition.
% TODO: Not error resilient, not checking array boundaries. Improve!
tagAtGT = zeros(2, numGaitTrans);
for nr=1:numLabel
    if nr~=numLabel
        s1=find(gaitTransTimes==labels(2,nr));
        s2=find(gaitTransTimes==labels(2,nr+1));
        padnum=s2-s1;
        if nr==1
            tagAtGT(1,1:s1-1)=labels(1,nr)*ones(1,s1-1);
            tagAtGT(2,1:s1-1)=gaitTransTimes(1:s1-1);
        end
        tagAtGT(1,s1:s2-1)=labels(1,nr)*ones(1,padnum);
        tagAtGT(2,s1:s2-1)=gaitTransTimes(s1:s2-1);
    elseif nr==numLabel
        s1=find(gaitTrans(2,:)==labels(2,nr));
        s2=numGaitTrans;
        tagAtGT(1,s1:s2)=labels(1,nr);
        tagAtGT(2,s1:s2)=gaitTransTimes(s1:s2);
    end
end

% Deduce Transition Tags at transition points
%tagAtGT0 =tagAtGT;
nr=1;
while nr<=numGaitTrans
    if nr~=numGaitTrans && tagAtGT(1,nr)~=tagAtGT(1,nr+1)
        % Transition occuring
        transTag = LOCO.TagT(tagAtGT(1,nr:nr+1));

        % Convert the tag at tagAtGT to a tag transition. Example:
        % ...3,3,*3*,6,6,6...  becomes  ...3,3,*36*,6,6,6...
        % By default, we imprint the transition on the same GT index.
        % However, there are certain conditions that we choose to imprint
        %   the transition on the next GT index instead,
        %   for example: ...3,3,*3*,36,6,6...
        putOnNext = false;

        if (transTag == LOCO.TWalkTStrA || transTag==LOCO.TStrATWalk) && gaitTrans(1,nr) ~= LOCO.ToeOff
            % Walk to StairA (or vice versa) should happen at toe off
            %  moment.
            putOnNext = true;

        elseif (transTag == LOCO.TRmpDTWalk || transTag==LOCO.TStrDTWalk) && gaitTrans(1,nr) ~= LOCO.HeelCo
            %Ramp decent to walk or SD to walk should happen at heel co 
            putOnNext = true;
        end

        % tagAtGT(1,nr+2) = transTag;
        % tagAtGT(1,nr+1:nr+1) = tagAtGT(1,nr);
        % nr = nr + 3;
        % continue

        if ~putOnNext
            % Store transition inplace, and that's it.
            tagAtGT(1,nr) = transTag;
        else
            % Store transition onto next slot, and skip next slot (see
            % below).
            tagAtGT(1,nr+1) = transTag;
            nr = nr + 1;
        end
    end

    % Go to next.
    nr=nr+1;
end

ProcessedTags=tagAtGT;
end

