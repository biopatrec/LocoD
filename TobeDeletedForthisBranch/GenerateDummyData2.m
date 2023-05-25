fs=2000;
LocoModeDuration=5;
numlocomotion=5;
numround=30;
signal=zeros(5,LocoModeDuration*numlocomotion*fs*numround);
FinalSignal=[];
j=1;
t=0:1/fs:LocoModeDuration;
%Walking
F = 25;
data1= sawtooth(2*pi*F*t);
%StairA
F = 100;
data2 = sin(2*pi*F*t);
%StairD
F = 150;
data3 = sin(2*pi*F*t);
%RampA
F = 200;
data4 = sin(2*pi*F*t);
%RampD
F = 250;
data5 = sin(2*pi*F*t);
for i=1:numround
    %Walking Ch1
    tag(1,j)= 3;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(1,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data1;
    j=j+1;
    %StairsA Ch 2
    tag(1,j)= 4;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(2,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data2;
    j=j+1;
    %Walking Ch1
    tag(1,j)= 3;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(1,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data1;
    j=j+1;
    %StairsD Ch 3
    tag(1,j)= 5;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(3,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data3;
    j=j+1;
    %Walking Ch1
    tag(1,j)= 3;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(1,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data1;
    j=j+1;
    %RampA Ch 4
    tag(1,j)= 6;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(4,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data4;
    j=j+1;
    %Walking Ch1
    tag(1,j)= 3;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(1,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data1;
    j=j+1;
    %RampD Ch 5
    tag(1,j)= 7;
    tag(2,j)= ((j-1)*fs*LocoModeDuration+1)/fs;
    signal(5,(j-1)*fs*LocoModeDuration+1:j*fs*LocoModeDuration+1)=data5;
    j=j+1;
 
    %FinalSignal=[signal,FinalSignal];
    %signal=[];
    %     plot (signal(1,1:j*fs*LocoModeDuration+1))
    %     hold on
    %     plot (signal(2,1:j*fs*LocoModeDuration+1))
    %     hold on
    %     plot (signal(3,1:j*fs*LocoModeDuration+1))
    %      figure
    %     plot (signal(4,1:j*fs*LocoModeDuration+1))
    %      hold on
    %     plot (signal(5,1:j*fs*LocoModeDuration+1))
end

dt = 1/fs;
StopTime = size(signal,2)/fs;
t = (0:dt:StopTime-dt)';
F = 3.4;
data = sin(2*pi*F*t);
OriginalPressureSensor=data;
OriginalPressureSensor=OriginalPressureSensor';

HardlimitPS = 8 + 1 * (OriginalPressureSensor < .15);


signal=[signal;  HardlimitPS];


% 
% plot(signal(1,:))
% hold on
% %plot(tag(2,:)*fs)
% hold on
% plot(HardlimitPS)


load('DummyData.mat')
signalCopy.originalPressureSignal=OriginalPressureSensor;
signalCopy.signal=signal;
signalCopy.tags=tag;

