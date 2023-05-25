clear all

recprops = RecordingProperties();
recprops.SamplingFreq = 500;
recprops.NumChannels= 2;
recprops.Device = "dummy";

sig = Signal(recprops);
sig.signal=rand(recprops.NumChannels,1000);
%sig.Savedata()

%sig.signal=sig.LoadSignal;

NumSample=sig.GetNumSample();
%numch=sig.GetNumChannel();
tagcounter=sig.GetNumTags();
[t_moment]=sig.GetTime();
numNewSample=2000;

sig.onSignalCallback = @uselessCallback;

sig.AppendSignal(rand(recprops.NumChannels,numNewSample),numNewSample);
sig.AddGroundTruthTags(1,t_moment);
sig.AddGroundTruthTags(2,t_moment+1);
sig.AddGroundTruthTags(3,t_moment+2);

disp('Saving...')
sig.SaveData();
disp('Loading...')
reloaded = sig.LoadSignal();
disp('Sig = ')
disp(sig)
disp('Reloaded = ')
disp(reloaded)

function uselessCallback(sig, numNewSample)
    disp('Callback!!!')
end



