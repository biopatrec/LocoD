%Offline classification codes, diffent algorithms can be added
function  [testLabelsPredicted,classifierModel,CC_3,CC_4,CC_5,CC_6,CC_7,CC_8,CC_9]=OfflineClassification(data,Lables,Prevlabel,ClassificationMethod,ClassificationType,Testpercentage,trainpercentage, validationpercentage,Architecture,ValidationMethode)
dType=ClassificationType;

Zindex=(Lables==0);
Lables(Zindex)=[];
data(Zindex,:)=[];
CC_3=[];CC_4=[];CC_5=[];CC_6=[];CC_7=[];CC_8=[];CC_9=[];

if ClassificationMethod=="LDA" && (Architecture~="Mode-Specific"&& Architecture~="Mode-Specific-PhaseDependant") && ValidationMethode~="LOOCV"

    data=[data,Lables'];
    [testdata,traindata,validationdata]=TestTrainValidSeperator(data,Testpercentage,trainpercentage, validationpercentage);
    Lables=testdata(:,end);
    trainlabel=traindata(:,end);
    testdata=testdata(:,1:end-1);
    traindata=traindata(:,1:end-1);
    try
        classifierModel = fitcdiscr(traindata, trainlabel, 'DiscrimType', dType);
    catch e
        disp(e)
        errordlg(e.message);
        accVset = [];
        coeff = [];
        return;
    end
    testLabelsPredicted = predict(classifierModel, testdata);

elseif ClassificationMethod=="LDA"  && (Architecture=="Binary" || Architecture=="All data-Phase dependant") && ValidationMethode=="LOOCV"
    dType=ClassificationType;

    try

        %classifierModel = fitcdiscr(data, Lables,'Leaveout','on', 'DiscrimType', dType);
        classifierModel = fitcdiscr(data, Lables,'KFold',100, 'DiscrimType', dType);

    catch e
        disp(e)
        errordlg(e.message);
        accVset = [];
        coeff = [];
        return;
    end

    testLabelsPredicted = kfoldPredict(classifierModel);


elseif ClassificationMethod=="SVM" &&  (Architecture=="Binary" || Architecture=="All data-Phase dependant")  && ValidationMethode=="10Fold"

    try
        SVMModel = fitcecoc(data, Lables);
        classifierModel = crossval(SVMModel);
        fitcsvm

    catch e
        disp(e)
        errordlg(e.message);
        accVset = [];
        coeff = [];
        return;
    end
    testLabelsPredicted = kfoldPredict(classifierModel);


elseif ClassificationMethod=="LDA" || ClassificationMethod=="SVM"  && (Architecture=="Mode-Specific" || Architecture~="Mode-Specific-PhaseDependant")% && ValidationMethode=="LOOCV" || ValidationMethode=="RondValidation"
   
    [testLabelsPredicted,classifierModel,CC_3,CC_4,CC_5,CC_6,CC_7,CC_9]=ModeSpecific(data,Lables,Prevlabel,ValidationMethode, dType,Testpercentage,trainpercentage, validationpercentage,ClassificationMethod);


    
else
    disp("This combinations has not been implemented yet")

end
if Architecture ~= "Mode-Specific" && Architecture~="Mode-Specific-PhaseDependant"
    figure

    %plotconfusion(testlabels,testLabelsPredicted');
    [C,order] = confusionmat(Lables,testLabelsPredicted');

    CC_3=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    for i=1:length(CC.ClassLabels)

        [lables_name{i,1},~]=GetTagName(CC.ClassLabels(i),[]);

    end


    y_Transition = diag(C) ./ sum(C,2)  % Precision
end







end