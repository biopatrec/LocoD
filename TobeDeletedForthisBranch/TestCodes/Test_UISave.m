function Test_UISave()
    x = [];
    x.data = [1 2 3; 4 5 6];
    x.recProps = RecordingProperties();

    uisave('x', './SavedData/data.mat');
end
