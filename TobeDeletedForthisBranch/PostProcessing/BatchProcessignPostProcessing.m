function [ss,tr,all,ss_N,tr_N,all_N]=BatchProcessignPostProcessing(RejectionThresh,filename, path)
%%Classess
close all
%clear all
processing= Processing();
%Signal= Signal();
%RejectionThresh=0.85;
validation=1;
%% Load a Folder
% locoDDir = fileparts(which('LocoD.m'));
% [filename, path] = uigetfile([locoDDir '/SavedData/*'], 'Select signal to load','MultiSelect','on');
%% Process for EMG+IMU LDAR

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
    [Result{i},numRejected(i),percentRejected(i)]=ReadyforClassificationPostProcessing(processing,sigData,1,1,1,RejectionThresh,validation);

end
[AllClass,SSClass,TrClass,wclass,wsaclass,wsdclass,wraclass,wrdclass,saclass,sdclass,rdclass,raclass,sawclass,sdwclass,rawclass,rdwclass,w,sa,sd,ra,rd,wsa,wrd,wsd,wra,raw,rdw,sdw,saw,ss,tr]=Calculatemean(Result);
Allmean=[3,w; 6,sa; 7,sd; 4,ra; 5,rd; 36, wsa; 37,wsd;34,wra;35,wrd;63,saw;73,sdw;43,raw;53,rdw];
meanofss=mean([w,sa,sd,ra,rd]);
meanoftr=mean([wsa,wrd,wra,saw,sdw,raw,rdw]);

close all;
%% Process Normal

for i=1:length(filename)

    processing.originalRecProps=[];
    fullpath = fullfile(path, filename{i});
    loadedSig=load(fullpath);
    loadedSig.signalCopy.filename=filename{i};
    loadedSig = loadedSig.signalCopy;
    sigData=loadedSig;
    recProps=sigData.recProps;
    processing.originalRecProps = recProps;
    [ResultN{i},numRejected_N(i)]=ReadyforClassificationPostProcessing(processing,sigData,1,1,0,RejectionThresh,validation);
end
[AllClass_N,SSClass_N,TrClass_N,wclass_N,wsaclass_N,wsdclass_N,wraclass_N,wrdclass_N,saclass_N,sdclass_N,rdclass_N,raclass_N,...
    sawclass_N,sdwclass_N,rawclass_N,rdwclass_N,...
    w_N,sa_N,sd_N,ra_N,rd_N,wsa_N,wrd_N,wsd_N,wra_N,raw_N,rdw_N,sdw_N,saw_N,ss_N,tr_N]=Calculatemean(ResultN);
AllmeanN=[3,w_N; 6,sa_N; 7,sd_N; 4,ra_N; 5,rd_N; 36, wsa_N; 37,wsd_N;34,...
    wra_N;35,wrd_N;63,saw_N;73,sdw_N;43,raw_N;53,rdw_N];
meanofssN=mean([w_N,sa_N,sd_N,ra_N,rd_N]);
meanoftrN=mean([wsa_N,wrd_N,wra_N,saw_N,sdw_N,raw_N,rdw_N]);

close all;

%% Do stat analysis
%%Stat only for SS
p_ssN = signrank(ss,ss_N);
%%Stat only for transition
p_trN = signrank(tr,tr_N);
%Stat for all
all=[ss;tr];
all_N=[ss_N;tr_N];
all=mean(all,1)';
all_N=mean(all_N,1)';
p_allN = signrank(all,all_N);

end