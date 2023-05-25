a=load('EMGTest_V13.mat');
b=a.signalCopy;
c=(b.signal)';
d=c(3,:);
%Filter
N   = 4;     % Order
FC1=20;
FC2=500;
sf=2000;

% Calculate the zpk values using the BUTTER function.
[z,p,k] = butter(N/2, [FC1 FC2]/(sf/2));

[sos_var,g] = zp2sos(z, p, k);
Hd          = dfilt.df2sos(sos_var, g);
c(3,:)      = filter(Hd,d);



plot(c(:,3:4))
c(:,4)=.001*c(:,4);
plot(c(:,3:4))
c(:,4)=.01*c(:,4);
plot(c(:,3:4))
c(:,4)=.0004+c(:,4);
plot(c(:,3:4))
plot(c(:,3),'Color',[0, 0,0]); 
hold on ;
plot(c(:,4),'k','LineWidth',1)