function [FusedFeature, FusedLabels]=SensorConcat(EMGfeatures,EMGLabels,IMUFeatures, PSFeatures)

switch nargin
    case 4
        FusedFeature=[EMGfeatures,IMUFeatures,PSFeatures];
        FusedLabels=EMGLabels;
    case 3
        FusedFeature=[EMGfeatures,IMUFeatures];
        FusedLabels=EMGLabels;
    case 2
        FusedFeature=EMGfeatures;
        FusedLabels=EMGLabels;
end

end