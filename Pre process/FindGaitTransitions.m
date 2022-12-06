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
%Find transitions from swing to stance and from stance to swing
% --------------------------Updates--------------------------


function [pressThrTrans]=FindGaitTransitions(pressureHardlimited,fs,DELTA_TIME_MIN)

% Extract swing<->stance transitions from pressure signal.
% Also don't record transitions if the passed time is very short.

sigLen = length(pressureHardlimited);
if nargin < 3
    DELTA_TIME_MIN = 0.1;
end
minSamplesBetweenTrans = DELTA_TIME_MIN * fs;
lastTransSample = -100000; % just set to a very negative time.
lastStablePressThres = pressureHardlimited(1,1);
fastTransMoments = []; % just for showing warnings
detectFastTrans = 0;
pressThrTrans = []; 

for n=2:sigLen
    % If there is a transition AND there is at least some time passed.
    P = pressureHardlimited(1,n);
    if P~=lastStablePressThres
        if n >= lastTransSample + minSamplesBetweenTrans
            if lastStablePressThres == 8 %Stance -> Swing TO
                pressThrTrans = [pressThrTrans [89; n]];
            elseif lastStablePressThres == 9 %Swing -> Stance HC
                pressThrTrans = [pressThrTrans [98; n]];
            else
                error('Invalid value in pressureThr %f. Not stance and not swing.', lastStablePressThres)
            end
    
            lastStablePressThres = P;
            lastTransSample = n;
            detectFastTrans = 0;
        else
            if detectFastTrans == 0
                % Report one more very fast transition. Just for the sake
                % of reporting.
                fastTransMoments = [fastTransMoments n];
                detectFastTrans = 1;
            end
        end
    end
end



end