clear all
close all
delete(timerfindall);
allfigs = findall(0, 'Type', 'figure');
delete(allfigs);

global plotAxe;
plotFig = figure;
plotAxe = axes('Parent', plotFig);

RP = RecordingProperties.CreateReplayRecprops('./SavedData/EMGTestBA2-1304.mat');
RP.Verify();
disp(RP);

RS = RecordingFunctions(RP);
RS.signal.onSignalCallback = @onDataInCallback;
RS.ConnectToDevice();
RS.StartRecording();
RS.RecordingStat = 1; % Already start

while isvalid(plotFig)
    pause(0.3);
end

disp('Okay that''s enough')
RS.StopRecording();
RS.Disconnect();

clear all
close all
delete(timerfindall);

function onDataInCallback(sig, numNewSample)
    global plotAxe
    if ~isvalid(plotAxe)
        return
    end
    fprintf("-> %d %d\n", sig.GetNumSample(), numNewSample);
    %plot(sig.signal(sig.recProps.IdxPS, :))
    plot(plotAxe, sig.originalPressureSignal)
end
