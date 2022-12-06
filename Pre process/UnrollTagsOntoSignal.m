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
% Spread sporadic tagging information onto the sampled signal.
% - verify that the signal tags follows a specific sequence.
% - remove similar consecutive tags (just to be sure)
% - "spread" tags under each sample in a new channel, so that status of system is indicated
%   in time domain.
% - indicate event transition moments.
% - snap tag-transition moments to nears gait-transition.
% - add +1000 and -1000 tags to show if it is transition or not
% --------------------------Updates--------------------------



function [availableTagName,signal,numRounds]=UnrollTagsOntoSignal(signal,tags,numAllCh,fs,gaitTrans,roundIncrementTag)
%SignalDuration=floor(length(signal)/fs);

% Get channel indices
idxTag = numAllCh+1;
idxTagTrans = numAllCh+2;
idxRound = numAllCh+3;
numTag = length(tags);
[~, sigLen] = size(signal);

MAX_TRANSITION_TO_GAIT_SNAP_DISTANCE = 1.0 * fs;

%%%%%%% Tags
% 0=
% 1= Sit
% 2= Stand
% 3= Walk
% 4= RampA
% 5= RampD
% 6= StairA
% 7= StairD
% 1000 Transition
% -1000 Steady

%AvailableTagName=[];

% Tag signals with transitions and put those tags in the nearest swing or
% stance.
% We iterate over discrete tag matrix, and for each one, we put the tag-value in the
%   tag-channel of the signal. Basically we convert from sporadic to
%   continuous.
for nr=1:numTag
    currentTag = tags(1,nr);
    currentTagTime = tags(2,nr);
    currentTagSample = floor(currentTagTime * fs) + 1;

    % First thing to do, has to do with current tag and **next** tag.
    % Put tag-value in tag-channel for upcoming samples.
    if nr == numTag
        nextTagSample = sigLen;
    else
        nextTagSample = floor(tags(2,nr+1) * fs) + 1;
    end
    signal(idxTag,currentTagSample+1:nextTagSample)=currentTag;

    % Second thing to do, has to do with current tag and **previous** tag.
    % Find transition moment between current and previous tag and snap
    %   it to closest heel contact/toe off moment.
    % Then put tag-transition-value at the tag-transition-moment in the
    %   tag-channel.
    if nr==1
        % Special about first tag: Set the tag-channel for previous data
        % points to the tag-value also.
        signal(idxTag,1:currentTagSample)=currentTag;
    else
        % Get previous tag
        prevTag = tags(1,nr-1);

        % if it is a transition
        if currentTag~=prevTag
            %Generate transition number
            tagTransition = prevTag*10 + currentTag;

            if tagTransition==36 ||   tagTransition==63 % || tagTransition==36%Walk to SA or SA to W happend in TO or Swing  89
                a=(gaitTrans(1,:)==89);
                gaitTransSwing=gaitTrans(:,a);

                [closestGTDist,closestGTIndex] = min(abs(currentTagSample - gaitTransSwing(2,:)));

                if closestGTDist < MAX_TRANSITION_TO_GAIT_SNAP_DISTANCE
                    % Snap to this gait transition moment.
                    closestGTSample = floor( gaitTransSwing(2,closestGTIndex));
                else
                    % No surrounding gate transition. Unlucky
                    closestGTSample = currentTagSample;
                end
                tagTransitionSample=closestGTSample;

            elseif tagTransition==53  ||   tagTransition==73 || tagTransition==34 %|| tagTransition==35 || tagTransition==37  %Ramp decent to walk or SD to walk Happens in HC or Stance 98
                a=(gaitTrans(1,:)==98);
                gaitTransStance=gaitTrans(:,a);

                [closestGTDist,closestGTIndex] = min(abs(currentTagSample - gaitTransStance(2,:)));

                if closestGTDist < MAX_TRANSITION_TO_GAIT_SNAP_DISTANCE
                    % Snap to this gait transition moment.
                    closestGTSample = floor( gaitTransStance(2,closestGTIndex));
                else
                    % No surrounding gate transition. Unlucky
                    closestGTSample = currentTagSample;
                end
                tagTransitionSample=closestGTSample;

            else  %Otherwise we choose the next transition
                for gt=1:length(gaitTrans(2,:))
                    if gaitTrans(2,gt)>currentTagSample
                        NextGTIndex=gt;
                        NextGTDist=gaitTrans(2,gt)-currentTagSample;
                        break;
                    end
                end

                if NextGTDist < MAX_TRANSITION_TO_GAIT_SNAP_DISTANCE
                    % Snap to this gait transition moment.
                    %closestGTSample = floor( gaitTrans(2,closestGTIndex));
                    closestGTSample = floor( gaitTrans(2,NextGTIndex));
                else
                    % No surrounding gate transition. Unlucky
                    closestGTSample = currentTagSample;
                end
                tagTransitionSample=closestGTSample;



            end
            % Insert the spike (tag-transition-value) onto signal
            signal(idxTag, tagTransitionSample) = tagTransition;

            if tagTransitionSample > currentTagSample
                % Tag-Transition to be stored after current tag
                % Extend time span of previous tag until transition moment.
                signal(idxTag,currentTagSample:tagTransitionSample-1)=tags(1,nr-1);
            else
                % Tag-Transition to be stored before current tag
                signal(idxTag,tagTransitionSample+1:currentTagSample)=tags(1,nr);
            end

            % Declare tag-transition moment on the closest gait-transition moment
            % FAULT: Results in O(nm) -- Complicated fix.
            % NOTE: Second row on GaitTransition is sample not seconds.
            %[closestGTDist,closestGTIndex] = min(abs(currentTagSample - gaitTrans(2,:)));
            %NextGTIndex


        else
            % No transition. Continue as usual.
        end
    end
end

% Append TagTrans channel.
availableTagName = unique(signal(idxTag, :));
IfTransition = (signal(idxTag, :) > 10) * 2000 - 1000;
signal=[signal; IfTransition];

% Append RoundCounter channel
roundIncrementFlag = (tags(1,:)==roundIncrementTag);
numRounds = sum(roundIncrementFlag);
roundStartTimes=tags(2,roundIncrementFlag);
lastRoundEndSample=0;

for nr=1:numRounds+1
    if nr <= numRounds
        n = round(roundStartTimes(nr)*fs);
    else
        n = sigLen;
    end
    signal(idxRound,(lastRoundEndSample+1):(n))=nr;
    lastRoundEndSample = n;
end


end