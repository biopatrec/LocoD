clear all
load('U:\LLP\LocoD-Github\SavedData\UsableData\TF008-16112022_1_Online_1.mat')

PS=signalCopy.signal(signalCopy.recProps.IdxPS,:);
% Extract swing<->stance transitions from pressure signal.
% Also don't record transitions if the passed time is very short.
% TODO: The logic is wrong. Correct logic is to NOT record transition if
%   the new state continued for so short.
sigLen = length(PS);
DELTA_TIME_MIN = 0.1;
fs=signalCopy.recProps.SamplingFreq;
minSamplesBetweenTrans = DELTA_TIME_MIN * fs;
lastTransSample = -100000; % just set to a very negative time.
lastStablePressThres = PS(1,1);
fastTransMoments = []; % just for showing warnings
detectFastTrans = 0;
pressThrTrans = []; 

for n=2:sigLen
    % If there is a transition AND there is at least some time passed.
    P = PS(1,n);
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
k=1;
for j=3:length(pressThrTrans)
    if pressThrTrans(1,j)==89
        stridlen(k)=pressThrTrans(2,j)-pressThrTrans(2,j-2);
        k=k+1;
    end
    
end
stridelenMean=mean(stridlen)/fs
