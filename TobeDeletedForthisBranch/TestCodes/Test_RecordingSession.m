
disp('Cleaning everything')
clear all
delete(timerfindall);

disp('Press anything')
pause();

recProps=RecordingProperties();
recSess=RecordingFunctions(recProps);
signal=Signal(recProps);

recProps.Device="dummy";
recProps.SamplingFreq = 2000;
recProps.NumChannels = 1;
recProps.ComType= 'WiFi';

recSess.signal.onSignalCallback = @(signal, numNewSample)plot(signal.signal);

% For GUI
% recSess.onSignalCallback = @app.OnPlotSignal
% OnPlotSignal(app, rs, numNewSample)

recSess.ConnectToDevice();
recSess.StartRecording();

uiwait(msgbox('Press okay to exit'))

gprlog('Exiting...');
delete(recSess);




