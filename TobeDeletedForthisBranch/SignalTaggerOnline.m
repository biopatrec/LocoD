%Add tags to the online signal
function [Manualtags]=SignalTaggerOnline(fs,ManualOnlineTags,PredictedTags)
%SignalDuration=floor(length(signal)/fs);

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

epsilon = 0.01;


%Tag mover

for i=1:length(ManualOnlineTags)
    [~,closestIndex] = min(abs(ManualOnlineTags(2,i)-PredictedTags(2,:)));
    closestTime = PredictedTags(2,closestIndex);
    ManualtagsNew(2,i)=closestTime;
    ManualtagsNew(1,i)=ManualOnlineTags(1,i);

end

j=1;

% Tag signals with transitions and put those tags in the nearest swing or
% stance
for s=1:length(PredictedTags)
    for i=1:length(ManualtagsNew)
    
        if abs(PredictedTags(2,s)-ManualtagsNew(2,i))<epsilon && i~=length(ManualOnlineTags)

            % if it is not the first tag or similar to the previouse one
            if i~=1 && ManualOnlineTags(1,i)~=ManualOnlineTags(1,i-1)% to avoid xx tags
               tagTransition = ManualtagsNew(1,i-1)*10 + ManualtagsNew(1,i);  %Generate transition number
               Manualtags(1,j)=tagTransition;
               Manualtags(2,j)= ManualtagsNew(2,i);
               j=j+1;
                
           

            end
        end
  
    end
   
end
disp("Tagging done")