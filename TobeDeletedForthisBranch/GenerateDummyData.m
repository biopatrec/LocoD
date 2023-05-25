clc;
clear all;
close all;
fs=2000;
f1 = 500;
f2 = 900;
f3 = 1100;
f4 = 1300;
f5 = 1500;
dt = 1/fs;
StopTime = 20;             % seconds per movemnt
t = (0:dt:StopTime-dt)';     % seconds
signal=[];
j=1;
rounds=50;
LocoModeDuration=5; %Seconds
for i=1:rounds


    %%Walking
    tc = gauspuls('cutoff',100,0.5,[],-40);
    t = -tc:1/fs:tc;
    x = gauspuls(t,100,0.5);
    ts = 0:1/1000:LocoModeDuration;
    d = [0:1:LocoModeDuration;sin(2*pi*0.02*(0:LocoModeDuration))]';
    data1 = pulstran(ts,d,x,fs);
    tag(1,j)= 3;
    if i~=1
        tag(2,j)= size(signal,2)/fs;
    else
        tag(2,j)=size(data1 ,2)/fs;
    end
    j=j+1;
    signal=[signal, data1];

    %%StairA
    fnx = @(x,fn) sin(2*pi*fn*x).*exp(-fn*abs(x));
    ffs = 1000;
    tp = 0:1/ffs:1;
    pp = fnx(tp,30);
    t = 0:1/fs:LocoModeDuration;
    d = 0:1/3:1;
    dd = [d;4.^-d]';

    data2 = pulstran(t,dd,pp,ffs);
    tag(1,j)= 4;
    if i~=1
        tag(2,j)= size(signal,2)/fs;
    else
        tag(2,j)=size(data2 ,2)/fs;
    end
    j=j+1;
    signal=[signal, data2];
    %     %%Walking
    %     tc = gauspuls('cutoff',100,0.5,[],-40);
    %     t = -tc:1/fs:tc;
    %     x = gauspuls(t,100,0.5);
    %     ts = 0:1/1000:LocoModeDuration;
    %     d = [0:1:LocoModeDuration;sin(2*pi*0.02*(0:LocoModeDuration))]';
    %     data1 = pulstran(ts,d,x,fs);
    %     tag(1,j)= 3;
    %     if i~=1
    %         tag(2,j)= size(signal,2)/fs;
    %     else
    %         tag(2,j)=size(data1 ,2)/fs;
    %     end
    %     j=j+1;
    %     signal=[signal, data1];
    %%StairD
    t = 0:1/fs:LocoModeDuration;
    d = [0:1:LocoModeDuration;sin(2*pi*0.0002*(0:LocoModeDuration))]';
    x = tripuls(t,0.1,-1);
    data3 = 800*pulstran(t,d,x,fs);
    tag(1,j)= 5;
    if i~=1
        tag(2,j)= size(signal,2)/fs;
    else
        tag(2,j)=size(data3 ,2)/fs;
    end
    j=j+1;
    signal=[signal, data3];
    %     %%Walking
    %     tc = gauspuls('cutoff',100,0.5,[],-40);
    %     t = -tc:1/fs:tc;
    %     x = gauspuls(t,100,0.5);
    %     ts = 0:1/1000:LocoModeDuration;
    %     d = [0:1:LocoModeDuration;sin(2*pi*0.02*(0:LocoModeDuration))]';
    %     data1 = pulstran(ts,d,x,fs);
    %     tag(1,j)= 3;
    %     if i~=1
    %         tag(2,j)= size(signal,2)/fs;
    %     else
    %         tag(2,j)=size(data1 ,2)/fs;
    %     end
    %     j=j+1;
    %     signal=[signal, data1];
    %%RampA
    %dt = 1/fs;
    %StopTime = LocoModeDuration*fs;
    t=0:1/fs:LocoModeDuration;
    F = 3;
    data4 = sin(2*pi*F*t);
    tag(1,j)= 6;
    if i~=1
        tag(2,j)= size(signal,2)/fs;
    else
        tag(2,j)=size(data4 ,2)/fs;
    end
    j=j+1;
    signal=[signal, data4];
    %     %%Walking
    %     tc = gauspuls('cutoff',100,0.5,[],-40);
    %     t = -tc:1/fs:tc;
    %     x = gauspuls(t,100,0.5);
    %     ts = 0:1/1000:LocoModeDuration;
    %     d = [0:1:LocoModeDuration;sin(2*pi*0.02*(0:LocoModeDuration))]';
    %     data1 = pulstran(ts,d,x,fs);
    %     tag(1,j)= 3;
    %     if i~=1
    %         tag(2,j)= size(signal,2)/fs;
    %     else
    %         tag(2,j)=size(data1 ,2)/fs;
    %     end
    %     j=j+1;
    %     signal=[signal, data1];

    plot(signal)
end

plot(signal)


dt = 1/fs;
StopTime = length(signal)/fs;
t = (0:dt:StopTime-dt)';
F = 3;
data = sin(2*pi*F*t);
OriginalPressureSensor=data;
OriginalPressureSensor=OriginalPressureSensor';
signal=signal';
HardlimitPS = 8 + 1 * (OriginalPressureSensor < .15);

signal=signal';
signal=[signal;  HardlimitPS];



load('DummyData.mat')
signalCopy.originalPressureSignal=OriginalPressureSensor;
signalCopy.signal=signal;
signalCopy.tags=tag;
