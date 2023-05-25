function [Result,numRejected,percentRejected]=ReadyforClassificationPostProcessing(processing,sigData,HasEMG,HasMech,PstProcessing,PstProcessingThresh,Validation)
sum_ST3=[];sum_ST4=[];sum_ST5=[];sum_ST7=[];sum_Sw3=[];sum_Sw6=[];
ST_CC_3=[]; ST_CC_4=[]; ST_CC_5=[]; ST_CC_7=[]; SW_CC_3=[];SW_CC_6=[];SW_CC_4=[];
%Process Which sensors?
processing.IfProcessEMG=HasEMG;
processing.IfProcessIMU=HasMech;
processing.IfProcessPS=HasMech;
%Filtering Data
processing.FilterOutBadRounds = 1;
processing.FilterType= ["Notch 50 HZ","20- 500 HZ"];
processing.IMUFilterType= "None";
%Data windowing
processing.BeforeEvent=.2;
processing.AfterEvent=.11;
processing.IncTime=0.03;
processing.WindowLength=.2;
processing.WindowingMethod='On gait phase(before and after)';
%Train Test
processing.TestPercent=.8;
processing.TrainPercent=.2;
processing.ValidPercent=0;
%Pre-Process
processing.TreatSignal(...
    sigData.signal, ...
    sigData.originalPressureSignal, ...
    sigData.tags);
%Extract Feature
if HasEMG==1
    processing.FetureSet=["tmabs",'twl' ,'tzc', 'tslpch2' ];
    processing.GetFeaturesEMG();
end
if HasMech==1
    processing.IMUFetureSet=  ["tmn",'tmax' ,'tmin', 'tstd' ];
    processing.GetFeaturesIMU();
    processing.GetFeaturesPS();
end

%Classification
processing.ClassificationMethod="LDA" ;
processing.ClassifierArchitecture="Mode-Specific-PhaseDependant";
processing.ClassifireValidation="10Fold";
processing.ClassificationType="PseudoLinear";

%Feature fusion
[processing.features_SW_all,processing.Lables_TransitionORSteady_SW_all]=SensorConcat(processing.features_SW_all,processing.Lables_TransitionORSteady_SW_all,processing.IMUfeatures_SW_all,processing.PSfeatures_SW_all);
[processing.features_ST_all,processing.Lables_TransitionORSteady_ST_all]=SensorConcat(processing.features_ST_all,processing.Lables_TransitionORSteady_ST_all,processing.IMUfeatures_ST_all,processing.PSfeatures_ST_all);

%Classification
%Swing
[~,ClassifierModel_SW_MS,MS_SW_CC_3,MS_SW_CC_4,MS_SW_CC_5,MS_SW_CC_6,MS_SW_CC_7,numRejected_SW,percentRejected_SW]=ModeSpecificPostProcessing(processing.features_SW_all,processing.Lables_SW_all,processing.PrevLabel_SW_all,PstProcessing,PstProcessingThresh,Validation,processing.TestPercent,processing.TrainPercent, processing.ValidPercent);
%Stance
[~,ClassifierModel_ST_MS,MS_ST_CC_3,MS_ST_CC_4,MS_ST_CC_5,MS_ST_CC_6,MS_ST_CC_7,numRejected_ST,percentRejected_ST]=ModeSpecificPostProcessing(processing.features_ST_all,processing.Lables_ST_all,processing.PrevLabel_ST_all,PstProcessing,PstProcessingThresh,Validation,processing.TestPercent,processing.TrainPercent, processing.ValidPercent);
numRejected=numRejected_SW+numRejected_ST;
percentRejected=(percentRejected_SW+percentRejected_ST)/2;

%Find accuracy percentages


%Remove vertically and horizontally the classes that are less than 10
st3=sum(MS_ST_CC_3.NormalizedValues,2);
st_C3=MS_ST_CC_3.NormalizedValues;
ST_CC_3ClassLabels=MS_ST_CC_3.ClassLabels;
n=1;
for m=1:length(sum(MS_ST_CC_3.NormalizedValues,2))
    if st3(m)<10
        st_C3(n,:)=[];
        st_C3(:,n)=[];
        ST_CC_3ClassLabels(n)=[];
    else
        n=n+1;
    end
end
sum_ST3=sum(st_C3,2);
ST_CC_3=diag(st_C3)./sum_ST3;

if length(MS_ST_CC_4.NormalizedValues)==2
    sum_ST4=sum(MS_ST_CC_4.NormalizedValues,2);
    if sum(sum_ST4(1))<10 || sum(sum_ST4(2))<10 %If row one or 2 has less than 10 samples discard it
        ST_CC_4ClassLabels=[];
        ST_CC_4=[];
    else
        ST_CC_4=diag(MS_ST_CC_4.NormalizedValues)./sum_ST4;
        ST_CC_4ClassLabels=MS_ST_CC_4.ClassLabels;
    end
else
    ST_CC_4ClassLabels=[];
    ST_CC_4=[];
end
sum_ST5=sum(MS_ST_CC_5.NormalizedValues,2);  sum_ST5(sum_ST5<10)=0;
sum_ST7=sum(MS_ST_CC_7.NormalizedValues,2);  sum_ST7(sum_ST7<10)=0;

%Remove vertically and horizontally the classes that are less than 10
sw3=sum(MS_SW_CC_3.NormalizedValues,2);
sw_C3=MS_SW_CC_3.NormalizedValues;
SW_CC_3ClassLabels=MS_SW_CC_3.ClassLabels;
n=1;
for m=1:length(sum(MS_SW_CC_3.NormalizedValues,2))
    if sw3(m)<10
        sw_C3(n,:)=[];
        sw_C3(:,n)=[];
        SW_CC_3ClassLabels(n)=[];
    else
        n=n+1;
    end
end
sum_SW3=sum(sw_C3,2);
SW_CC_3=diag(sw_C3)./sum_SW3;

if length(MS_SW_CC_4.NormalizedValues)==2
    sum_SW4=sum(MS_SW_CC_4.NormalizedValues,2);
    if sum(sum_SW4(1))<10 || sum(sum_SW4(2))<10 %If row one or 2 has less than 10 samples discard it
        SW_CC_4ClassLabels=[];
        SW_CC_4=[];
    else
        SW_CC_4=diag(MS_SW_CC_4.NormalizedValues)./sum_SW4;
        SW_CC_4ClassLabels=MS_SW_CC_4.ClassLabels;
    end

else
    SW_CC_4ClassLabels=[];
    SW_CC_4=[];
end

sum_SW6=sum(MS_SW_CC_6.NormalizedValues,2);  sum_SW6(sum_SW6<10)=0;


ST_CC_5=diag(MS_ST_CC_5.NormalizedValues)./sum_ST5;
ST_CC_7=diag(MS_ST_CC_7.NormalizedValues)./sum_ST7;
SW_CC_6=diag(MS_SW_CC_6.NormalizedValues)./sum_SW6;


Val=[ST_CC_3;ST_CC_5...
    ;ST_CC_7;SW_CC_3;ST_CC_4;SW_CC_4;...
    SW_CC_6];
%Save in an array
Lbl=[ST_CC_3ClassLabels;MS_ST_CC_5.ClassLabels...
    ;MS_ST_CC_7.ClassLabels;...
    SW_CC_3ClassLabels;ST_CC_4ClassLabels;SW_CC_4ClassLabels;MS_SW_CC_6.ClassLabels];

res=[Lbl,Val];

Result=res;

end