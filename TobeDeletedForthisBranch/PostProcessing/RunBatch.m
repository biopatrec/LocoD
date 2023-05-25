%Instrusction
%1. Put this script in PostProcessing folder
%2. Go to LocoD folder and in command window type LocoD
%3. Put the desired threshold and increment steps run this code


%This cod will run batch processing with different rejection thresholds
clear all;

Threshold=0.65:0.1:0.85;     %Fill Threshold And increment steps
NumConditions=length(Threshold);

%Load files

locoDDir = fileparts(which('LocoD.m'));
[filename, path] = uigetfile([locoDDir '/SavedData/*'], 'Select signal to load','MultiSelect','on');

for i=1:NumConditions
    %%ss: Accuracy of everyone WITH REJECTION and in steady-state
    %tr: Accuracy of everyone WITH REJECTION and in transition
    %all: Accuracy everyone in average of transition and transition WITH REJECTION
    %%ss_N: Accuracy of everyone WITHOUT REJECTION and in steady-state (N REFERS TO NORMAL)
    %tr_N: Accuracy of everyone WITHOUT REJECTION and in transition
    %all_N: Accuracy everyone in average of transition and transition WITHOUT REJECTION


[ss{i},tr{i},all{i}]=BatchProcessignPostProcessing(Threshold(i),filename, path);

end