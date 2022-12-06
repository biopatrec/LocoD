% ---------------------------- Copyright Notice ---------------------------
% This file is part of LocoD © which is open and free software under
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for
% the full license governing this code and copyrights.
%
% LocoD was initially developed by Bahareh Ahkami at
% Center for Bionics and Pain research and Chalmers University of Technology.
% All authors’ contributions must be kept
% acknowledged below in the section "Updates % Contributors".
%
% Would you like to contribute to science and sum efforts to improve
% amputees’ quality of life? Join this project! or, send your comments to:
% ahkami@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file
% linked to LocoD. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).

% acknowledge contributions here and in the project web page (optional).
% ------------------- Function Description ------------------
% Offline classification codes, diffent algorithms can be added
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation


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
        SVMModel = fitcecoc(data, Lables,'KFold',10);
        
       

    catch e
        disp(e)
        errordlg(e.message);
        accVset = [];
        coeff = [];
        return;
    end
    testLabelsPredicted = kfoldPredict(SVMModel);


elseif ClassificationMethod=="SVM" &&  (Architecture=="Binary" || Architecture=="All data-Phase dependant")  && ValidationMethode==" "

disp("NOT IMPLEMENTED YET");


elseif ClassificationMethod=="LDA" || ClassificationMethod=="SVM"  && (Architecture=="Mode-Specific" || Architecture~="Mode-Specific-PhaseDependant")% && ValidationMethode=="LOOCV" || ValidationMethode=="RondValidation"
   
    [testLabelsPredicted,classifierModel,CC_3,CC_4,CC_5,CC_6,CC_7,CC_9]=ModeSpecific(data,Lables,Prevlabel,ValidationMethode, dType,Testpercentage,trainpercentage, validationpercentage,ClassificationMethod);


    
else
    disp("This combinations has not been implemented yet")

end
if Architecture ~= "Mode-Specific" && Architecture~="Mode-Specific-PhaseDependant"
    figure

    %plotconfusion(testlabels,testLabelsPredicted');
    [C,order] = confusionmat(Lables,testLabelsPredicted');

    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    for i=1:length(CC.ClassLabels)

        [lables_name{i,1},~]=GetTagName(CC.ClassLabels(i),[]);

    end


    y_Transition = diag(C) ./ sum(C,2)  % Precision
end







end