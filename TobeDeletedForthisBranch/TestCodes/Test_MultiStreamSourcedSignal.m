clear all
close all

M = MultiStreamSourcedSignal();

SF0 = 2000;
SF1 = SF0 / 13.5;
t = 0;
n0A = 0;
n0B = 0;
n1A = 0;
n1B = 0;

DS0 = zeros(2,0);
DS1 = zeros(2,0);

M.Initialize({'MAIN', 'AUX'}, [2 2], [SF0 SF1]);

T1 = 0;

while 1
    pause (0.2)
    t = t + 0.2; 
    n0B = floor((t + (rand(1, 1) * 2 - 1) * 0.03) * SF0);
    n1B = floor((t + (rand(1, 1) * 2 - 1) * 0.03) * SF1);
    t0 = (n0A : n0B - 1) / SF0;
    t1 = (n1A : n1B - 1) / SF1;
    sig0 = [sin(t0 * 2 * pi * 0.455); sawtooth(t0 * 2 * pi * 1)];
    sig1 = [sin(t1 * 2 * pi * 0.455); sawtooth(t1 * 2 * pi * 1)];
    sig0 = sig0 + randn(size(sig0)) * 0.01;
    sig1 = sig1 + randn(size(sig1)) * 0.01;
    n0A = n0B;
    n1A = n1B;

    M.PushIntoStream('MAIN', sig0);

    T1 = T1 + 1;
    if T1 ~= 15
        M.PushIntoStream('AUX', sig1);
    end

    if T1 == 80
        M.PushIntoStream('AUX', sig1);
        M.PushIntoStream('AUX', sig1);
        M.PushIntoStream('AUX', sig1);
    end
    
    D = M.SyncAndSubmit(0);
    DS0 = [DS0 D{1,2}];
    DS1 = [DS1 D{2,2}];
    format shortG
    %disp([M.S{1}.SyncData.ReferenceSample / SF0, M.S{1}.TimeLen, M.S{1}.SF, M.S{2}.SyncData.ReferenceTime, M.S{2}.TimeLen, M.S{2}.SF])
    
    
    Mode = 1;
    
    for p = 1 : 2
        if Mode == 0
            subplot(2, 1, p)
            hold off
            plot(sig0(p,:))
            hold on
            plot(sig1(p,:))
        else
            subplot(2, 1, p)
            hold off
            plot(DS0(p,:))
            hold on
            plot(DS1(p,:))
        end
    end
end

