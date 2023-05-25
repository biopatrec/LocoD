
clear all

%% Load data from offline recording which will be used for training

offlineDataset = Signal.LoadSignal();
recProps=offlineDataset.recProps;
recSess=RecordingFunctions(recProps);
%% Create recording session for online

sF=offlineDataset.recProps.SamplingFreq;
nCh=offlineDataset.recProps.NumChannels;

deviceName  = recProps.Device;
%ComPortType = recProps.ComType;

%deviceName="dummy";

%% Get windowing params
global nWindow
tWindow=0.2;
tOverlap=0.05;
nWindow=round(tWindow * sF); % Samples corresponding Time window
nOverlap=round(tOverlap * sF);   % Samples correcponding overlap
global nNonOverlap
nNonOverlap = nWindow - nOverlap;

%% Real time window-splitting state
global nNextWindowStart
global numExtracted
nNextWindowStart = 0;
numExtracted = 0;

%% Load classifier
global classifierModel

classifierModel=load('classifierModel');

%% Create filter
bpf = []
global bpf

%% Connect the chosen device and start recording session.
% Set the selected device and Start the acquisition
%recProps.Device="dummy";
recSess.ConnectToDevice();
recSess.signal.onSignalCallback = @onDataInCallback;
recSess.StartRecording();

%% Wait for demo to finish
uiwait(msgbox('Press okay to exit'))

gprlog('Exiting...');
delete(recSess);

%% Main data callback
function onDataInCallback(sig, numNewSample)

global nNextWindowStart
global numExtracted
global nWindow
global nNonOverlap

global classifierModel

n1 = sig.GetNumSample();
sF= sig.recProps.SamplingFreq;
nNextWindowEnd = nNextWindowStart + nWindow;

while n1 >= nNextWindowEnd
    % Can extract at least one window
    numExtracted = numExtracted + 1;
    window = sig.signal(:, nNextWindowStart + 1:nNextWindowEnd);
    
    fprintf("Window %d extract (range %f ~ %f)\n", ...
        numExtracted, nNextWindowStart / sF, nNextWindowEnd / sF);
    
    % Update window-splitting state
    nThereafterWindowStart = nNextWindowStart + nNonOverlap;
    nNextWindowStart = nThereafterWindowStart;
    nNextWindowEnd = nNextWindowStart + nWindow;
    
    
    %Filter
   
    %Notch
    N   = 6;  % Order
    Fc1 = 49;  % First Cutoff Frequency
    Fc2 = 51;  % Second Cutoff Frequency
    
    [z,p,k] = butter(N/2, [Fc1 Fc2]/(sF/2), 'stop');
    
    [sos_var,g] = zp2sos(z, p, k);
    Hd50 = dfilt.df2sos(sos_var, g);
    
    window = filter(Hd50,window);
    
    
    % Bandpass filter
    N   = 4;     % Order
    FC1=20;
    FC2=400;
    
    % Calculate the zpk values using the BUTTER function.
    [z,p,k] = butter(N/2, [FC1 FC2]/(sF/2));
    
    [sos_var,g] = zp2sos(z, p, k);
    Hd          = dfilt.df2sos(sos_var, g);
    %signal      = filtfilt(sos_var,g,signal);
    window      = filter(Hd50,window);
    
    
    %Feature extraction
    features = ["tmabs";'twl' ;'tzc'; 'tslpch2' ];
    tFeatures = GetSigFeatures(window',sF,features);
    
    tSet = [];
    for i = 1 : size(features,1)
        tSet = [tSet , tFeatures.(features{i})];
    end
    
    %Classification
    LabelePredicted = predict(classifierModel.classifierModel, tSet);
    disp(LabelePredicted);
    
end


end