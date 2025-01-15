close all

%TF001,TF004,TF005,TF006,TF008,avg
%TF005 data with 4 windows other with 2

walk_3= [3.3074,6.1466,16.6667,14.5923,8.1501];
rampa_4= [2.9126,4.8077,36.3636,2.0833,8.2192];
rampd_5= [0,7.0796,18.7500,23.5294,4.7619];
staira_6=[0,0,7.1429,17.7215,2.1277];
staird_7=[6.7797,11.3821,23.4043,0,45.4545];

wsa_36=[0,12.5,6.2500,21.4286,6.25];
wsd_37=[5,0,6.2500,0,37.5];
wra_34=[0,7.874,46.6667,0,28];
wrd_35=[0,0,12.5000,28.5714,6.6667];
saw_63=[0,0,6.25,21.4286,0];
sdw_73=[0,25,6.25,7.1429,28.5714];
raw_43=[0,12.5,31.25,7.1429,6.25];
rdw_53=[5,6.25,0,14.2857,6.25];

ss=[3,6.25,26,13,6.25];
tr=[2,8,26,13,12];
trmean1=[19.1748,19.54762,11.78572,12.25];
trmean2=[11.42858,7.60714,5.53572,13.39286];
all=[3,7,26,13,9];



b=bar([3 4 5 6 7 ],[walk_3' rampa_4' rampd_5' staira_6' staird_7']');
for i=1:length(walk_3)
    xtips1 = b(i).XEndPoints;
    ytips1 = b(i).YEndPoints;
    labels1 = string(round(b(i).YData));
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end
legend('TF1','TF2','TF3','TF4','TF5');
xline(3.5,'--');
xline(4.5,'--');
xline(5.5,'--');
xline(6.5,'--');
legend('TF1','TF2','TF3','TF4','TF5');

figure

b=bar([34 35 36 37],[wra_34' wrd_35' wsa_36' wsd_37']');
for i=1:length(wra_34)
    xtips1 = b(i).XEndPoints;
    ytips1 = b(i).YEndPoints;
    labels1 = string(round(b(i).YData));
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end
hold on
xline(34.5,'--');
xline(35.5,'--');
xline(36.5,'--');
legend('TF1','TF2','TF3','TF4','TF5');
figure

b=bar([43 53 63 73],[raw_43' rdw_53' saw_63' sdw_73']');
for i=1:length(wra_34)
    xtips1 = b(i).XEndPoints;
    ytips1 = b(i).YEndPoints;
    labels1 = string(round(b(i).YData));
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom')
end
hold on
xline(48,'--');
xline(58,'--');
xline(68,'--');
legend('TF1','TF2','TF3','TF4','TF5');














