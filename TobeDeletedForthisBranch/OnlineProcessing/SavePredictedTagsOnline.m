%Save predicted tags in online to be used later for accuracy calculation
function PredictedtagsOnline=SavePredictedTagsOnline(LabelePredicted,time,PredictedtagsOnline)

NewEntry=[LabelePredicted;time];
PredictedtagsOnline=[PredictedtagsOnline,NewEntry];


end