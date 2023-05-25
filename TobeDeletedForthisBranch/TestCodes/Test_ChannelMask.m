clear -global
close all
delete(timerfindall);

rp = RecordingProperties('dummy');
rp.ChannelSelectionEMG = [1 4 7];
rp.ChannelSelectionIMU = [2 5 6];
rp.ChannelSelectionPS = [8];
rp.ChannelMaskInclusion([3], 0)
rp.GatherPostTranspositionChannelConfig();
app = GUI_ChannelMask(rp);
while isvalid(app)
    pause(0.5)
end

% again
app = GUI_ChannelMask(rp);
while isvalid(app)
    pause(0.5)
end

disp(rp)