%%Classess
close all
clear all
processing= Processing();
%Signal= Signal();

%% Load a Folder

locoDDir = fileparts(which('LocoD.m'));

[filename, path] = uigetfile([locoDDir '/SavedData/*'], 'Select signal to load','MultiSelect','on');


%% Process for EMG+IMU

for i=1:length(filename)

    processing.originalRecProps=[];
    fullpath = fullfile(path, filename{i});
    loadedSig=load(fullpath);
    loadedSig.signalCopy.filename=filename{i};
    loadedSig = loadedSig.signalCopy;
    sigData=loadedSig;

    recProps=sigData.recProps;
    recProps.ChannelMaskUnset();
    processing.originalRecProps = recProps;
    Result{i}=ReadyforClassification(processing,sigData,1,1);

end
[AllClass,SSClass,TrClass,wclass,wsaclass,wsdclass,wraclass,wrdclass,saclass,sdclass,rdclass,raclass,sawclass,sdwclass,rawclass,rdwclass,w,sa,sd,ra,rd,wsa,wrd,wsd,wra,raw,rdw,sdw,saw,ss,tr]=Calculatemean(Result);
Allmean=[3,w; 6,sa; 7,sd; 4,ra; 5,rd; 36, wsa; 37,wsd;34,wra;35,wrd;63,saw;73,sdw;43,raw;53,rdw];
meanofss=mean([w,sa,sd,ra,rd]);
meanoftr=mean([wsa,wrd,wra,saw,sdw,raw,rdw]);


%% Process for only IMU

for i=1:length(filename)

    processing.originalRecProps=[];
    fullpath = fullfile(path, filename{i});
    loadedSig=load(fullpath);
    loadedSig.signalCopy.filename=filename{i};
    loadedSig = loadedSig.signalCopy;
    sigData=loadedSig;

    recProps=sigData.recProps;
%     recProps.ChannelMaskInclusion(recProps.UnmaskedIdxIMU(1:6), 0);
    processing.originalRecProps = recProps;
    %%Treat Signal
    ResultIMU{i}=ReadyforClassification(processing,sigData,0,1);

end
[AllClass_IMU,SSClass_IMU,TrClass_IMU,wclass_IMU,wsaclass_IMU,wsdclass_IMU,wraclass_IMU,wrdclass_IMU,saclass_IMU,sdclass_IMU,rdclass_IMU,raclass_IMU,...
    sawclass_IMU,sdwclass_IMU,rawclass_IMU,rdwclass_IMU,...
    w_IMU,sa_IMU,sd_IMU,ra_IMU,rd_IMU,wsa_IMU,wrd_IMU,wsd_IMU,wra_IMU,raw_IMU,rdw_IMU,sdw_IMU,saw_IMU,ss_IMU,tr_IMU]=Calculatemean(ResultIMU);
AllmeanIMU=[3,w_IMU; 6,sa_IMU; 7,sd_IMU; 4,ra_IMU; 5,rd_IMU; 36, wsa_IMU; 37,wsd_IMU;34,...
    wra_IMU;35,wrd_IMU;63,saw_IMU;73,sdw_IMU;43,raw_IMU;53,rdw_IMU];
meanofssIMU=mean([w_IMU,sa_IMU,sd_IMU,ra_IMU,rd_IMU]);
meanoftrIMU=mean([wsa_IMU,wrd_IMU,wra_IMU,saw_IMU,sdw_IMU,raw_IMU,rdw_IMU]);


%% Process only EMG
for i=1:length(filename)

    processing.originalRecProps=[];
    fullpath = fullfile(path, filename{i});
    loadedSig=load(fullpath);
    loadedSig.signalCopy.filename=filename{i};
    loadedSig = loadedSig.signalCopy;
    sigData=loadedSig;

    recProps=sigData.recProps;
    processing.originalRecProps = recProps;
    %%Treat Signal
    Result_EMG{i}=ReadyforClassification(processing,sigData,1,0);

end
[AllClass_EMG,SSClass_EMG,TrClass_EMG,wclass_EMG,wsaclass_EMG,wsdclass_EMG,wraclass_EMG,wrdclass_EMG,saclass_EMG,sdclass_EMG...
    ,rdclass_EMG,raclass_EMG,sawclass_EMG,sdwclass_EMG,rawclass_EMG,rdwclass_EMG,w_EMG,sa_EMG,sd_EMG,ra_EMG,rd_EMG,wsa_EMG,wrd_EMG,wsd_EMG,wra_EMG,raw_EMG,rdw_EMG,sdw_EMG,saw_EMG,ss_EMG,tr_EMG]=Calculatemean(Result_EMG);
AllmeanEMG=[3,w_EMG; 6,sa_EMG; 7,sd_EMG; 4,ra_EMG; 5,rd_EMG; 36, wsa_EMG; 37,wsd_EMG;34,wra_EMG;35,wrd_EMG;63,saw_EMG;73,sdw_EMG;43,raw_EMG;53,rdw_EMG];
meanofssEMG=mean([w_EMG,sa_EMG,sd_EMG,ra_EMG,rd_EMG]);
meanoftrEMG=mean([wsa_EMG,wrd_EMG,wra_EMG,saw_EMG,sdw_EMG,raw_EMG,rdw_EMG]);

close all;


%% Do stat analysis
% 
% 
% 
%%Stat only for SS

p_ssIMU = signrank(ss,ss_IMU);
p_ssIMUEMG = signrank(ss_EMG,ss_IMU);
p_ssEMG=signrank(ss_EMG,ss);

%%Stat only for transition

p_trIMUEMG = signrank(tr_EMG,tr_IMU);
p_trIMU=signrank(tr,tr_IMU);
p_trEMG=signrank(tr_EMG,tr);



%Stat for all

all=[ss;tr];
all_EMG=[ss_EMG;tr_EMG];
all_IMU=[ss_IMU;tr_IMU];

all=mean(all,1)';
all_EMG=mean(all_EMG,1)';
all_IMU=mean(all_IMU,1)';

p_allIMU = signrank(all,all_IMU);
p_allIMUEMG = signrank(all_EMG,all_IMU);
p_allEMG=signrank(all_EMG,all);





