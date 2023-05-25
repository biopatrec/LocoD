%Lod Signal

load('Tf004-31082022_4_Online_2.mat')
sf=2000;
%IMU
IMUs= signalCopy.signal(10:27,:);
%Filter all IMU channels 
%plot(IMU_2_Y)
% Bandpass filter
N   = 4;     % Order
FC1=1;
FC2=20;

% Calculate the zpk values using the BUTTER function.
[z,p,k] = butter(N/2, [FC1 FC2]/(sf/2));

[sos_var,g] = zp2sos(z, p, k);
Hd          = dfilt.df2sos(sos_var, g);
IMUs_f = filter(Hd,IMUs,2);
% hold on
% plot(IMU_2_Y_f)
figure
 hold on
 j=-.4;
for i=7
    plot(IMUs_f(i,:)/max(IMUs_f(i,:))+j)
    j=j+.4;
   % hold on
end

%Plot original Pressure Signal
plot(signalCopy.originalPressureSignal/max(signalCopy.originalPressureSignal)-1)

% Plot EMG
% EMG_1=signalCopy.signal(1,:);
% hold on
% plot((EMG_1)/max(EMG_1)+5)

% Plot Pressure sensor
hold on
PS= signalCopy.signal(9,:);
plot((PS/max(PS))-2)

% Plot line on tags
tags=signalCopy.tags(2,:)*sf;
tagnumber=signalCopy.tags(1,:);
for i=1:length(tags)
    if tagnumber(i)==3
        color='k'; %walking
    elseif tagnumber(i)==4
        color='r'; %rampa
    elseif tagnumber(i)==5
        color='g'; %rampd
    elseif tagnumber(i)==6
        color='b'; %staira
    elseif tagnumber(i)==7
        color='m'; %staird
    end

    xline(tags(i),color)
end

%calculate difference

%Move tags to where they should be