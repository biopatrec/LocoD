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
% Mode specific processing with 10-fold validation and with no validation
% Other tyoes of classification and validation for Mode-s[ecific
% archtecture can be added to this file.
%
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation



function [testLabelsPredicted,classifierModel,CC_3,CC_4,CC_5,CC_6,CC_7,CC_8,CC_9]= ModeSpecific(data,Lables,Prevlabel, ValidationMethode,dType,Testpercentage,trainpercentage, validationpercentage,ClassificationMethod)
tg_3=1; tg_4=1; tg_5=1; tg_6=1; tg_7=1; tg_8=1; tg_9=1;
lable_8=0;
CC_3=[];CC_4=[];CC_5=[];CC_6=[];CC_7=[];CC_8=[];CC_9=[];

classifierModel={};
lable_3=[];lable_4=[];lable_5=[];lable_6=[];lable_7=[];lable_8=[];lable_9=[];


%% Categorize data
for i=1:length(Prevlabel)
    if (Prevlabel(i)==3 ||   floor(Prevlabel(i) /10)==3)  && (Lables(i) == 3 || Lables(i) == 34 || Lables(i) == 35 || Lables(i) == 36 || Lables(i) == 37 || Lables(i) == 38 || Lables(i) == 39)
        % 3 (walking) can have transition to all the movments so if the
        % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
        % 39
        %  classifier with these data in it
        lable_3(tg_3) = Lables(i);
        data_3(tg_3,:) = data(i,:);
        tg_3=tg_3+1;

    elseif (Prevlabel(i)==4  ||   floor(Prevlabel(i) /10)==4)  && (Lables(i) == 4 || Lables(i) == 43 || Lables(i) == 48)
         %If Previouse label was 4 current lable should be 4 or a
         %transition from 4 to 3
         
        lable_4(tg_4) = Lables(i);
        data_4(tg_4,:) = data(i,:);
        tg_4=tg_4+1;
 
    elseif (Prevlabel(i)==5  ||   floor(Prevlabel(i) /10)==5) && (Lables(i) == 5 || Lables(i) == 53 || Lables(i) == 58)
         %If Previouse label was 5 current lable should be 5 or a
         %transition from 5 to 3
        lable_5(tg_5) = Lables(i);
        data_5(tg_5,:) = data(i,:);
        tg_5=tg_5+1;


    elseif (Prevlabel(i)==6  ||   floor(Prevlabel(i) /10)==6)  && (Lables(i) == 6 || Lables(i) == 63 || Lables(i) == 68)
         %If Previouse label was 6 current lable should be 6 or a
         %transition from 6 to 3
        lable_6(tg_6) = Lables(i);
        data_6(tg_6,:) = data(i,:);
        tg_6=tg_6+1;

    elseif (Prevlabel(i)==7  ||   floor(Prevlabel(i) /10)==7)  && (Lables(i) == 7 || Lables(i) == 73 || Lables(i) == 78)
         %If Previouse label was 7 current lable should be  7or a
         %transition from 7 to 3
        
        lable_7(tg_7) = Lables(i);
        data_7(tg_7,:) = data(i,:);
        tg_7=tg_7+1;


    elseif (Prevlabel(i)==8  ||   floor(Prevlabel(i) /10)==8)  && (Lables(i) == 8 || Lables(i) == 83 || Lables(i) == 84 || Lables(i) == 85  || Lables(i) == 86 || Lables(i) == 87)
        lable_8(tg_8) = Lables(i);
        data_8(tg_8,:) = data(i,:);
        tg_8=tg_8+1;

    elseif (Prevlabel(i)==9  ||   floor(Prevlabel(i) /10)==9)



    end
end
%% 10 fold
if ValidationMethode=="10Fold"
    if ~isempty(lable_3)
        try
            %classifier for class 3 (Walking)
            if ClassificationMethod=="LDA"
                classifierModel_3 = fitcdiscr(data_3, lable_3,'KFold',10, 'DiscrimType', dType);
            elseif ClassificationMethod=="SVM"
                classifierModel_3= fitcecoc(data_3, lable_3,'KFold',10);
            end

            classifierModel{1}=classifierModel_3;

        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        
        testLabelsPredicted_3 = kfoldPredict(classifierModel_3);
        [C,order] =confusionmat(lable_3,testLabelsPredicted_3');
        figure
        CC_3=confusionchart(C,order);
        CC_3.RowSummary = 'row-normalized';
        CC_3.ColumnSummary = 'column-normalized';
        CC_3.Title = "Walking";

    end
     %classifier for class 4
    if ~isempty(lable_4)
        try

            if ClassificationMethod=="LDA"
                classifierModel_4 = fitcdiscr(data_4, lable_4,'KFold',10, 'DiscrimType', dType);
               
            elseif ClassificationMethod=="SVM"
                classifierModel_4= fitcecoc(data_4, lable_4,'KFold',10);
            end
            classifierModel{2}=classifierModel_4; %Save Classifier in a cell
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
       
        testLabelsPredicted_4 = kfoldPredict(classifierModel_4);
        [C,order] =confusionmat(lable_4,testLabelsPredicted_4');
        figure
        CC_4=confusionchart(C,order);
        CC_4.RowSummary = 'row-normalized';
        CC_4.ColumnSummary = 'column-normalized';
        CC_4.Title = "RampA";

    end
    %classifier for class 5
    if ~isempty(lable_5)
        try

            if ClassificationMethod=="LDA"
                classifierModel_5 = fitcdiscr(data_5, lable_5,'KFold',10, 'DiscrimType', dType);
            elseif ClassificationMethod=="SVM"
                classifierModel_5= fitcecoc(data_5, lable_5,'KFold',10);
            end
            classifierModel{3}=classifierModel_5;

        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        
        testLabelsPredicted_5 = kfoldPredict(classifierModel_5);
        [C,order] =confusionmat(lable_5,testLabelsPredicted_5');
        figure
        CC_5=confusionchart(C,order);
        CC_5.RowSummary = 'row-normalized';
        CC_5.ColumnSummary = 'column-normalized';
        CC_5.Title = "RampD";
    end

    %classifier for class 6
    if ~isempty(lable_6)
        try
           if ClassificationMethod=="LDA"
               classifierModel_6 = fitcdiscr(data_6, lable_6,'KFold',10, 'DiscrimType', dType);
           elseif ClassificationMethod=="SVM"
               classifierModel_6= fitcecoc(data_6, lable_6,'KFold',10);
           end
            classifierModel{4}=classifierModel_6;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        
        testLabelsPredicted_6 = kfoldPredict(classifierModel_6);
        [C,order] =confusionmat(lable_6,testLabelsPredicted_6');
        figure
        CC_6=confusionchart(C,order);
        CC_6.RowSummary = 'row-normalized';
        CC_6.ColumnSummary = 'column-normalized';
        CC_6.Title = "StairA";

    end
    %classifier for class 7
    if ~isempty(lable_7)
        try
            if ClassificationMethod=="LDA"
                classifierModel_7 = fitcdiscr(data_7, lable_7,'KFold',10, 'DiscrimType', dType);
            elseif ClassificationMethod=="SVM"
                classifierModel_7= fitcecoc(data_7, lable_7,'KFold',10);
            end
            classifierModel{5}=classifierModel_7;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        
        testLabelsPredicted_7 = kfoldPredict(classifierModel_7);
        [C,order] = confusionmat(lable_7,testLabelsPredicted_7');
        figure
        CC_7=confusionchart(C,order);
        CC_7.RowSummary = 'row-normalized';
        CC_7.ColumnSummary = 'column-normalized';
        CC_7.Title = "StairD";

    end
    %classifier for class 8
    if ~isempty(lable_8) && length(lable_8)>5
        try
            if ClassificationMethod=="LDA"
                classifierModel_8 = fitcdiscr(data_8, lable_8,'KFold',10, 'DiscrimType', dType);
            elseif ClassificationMethod=="SVM"
                classifierModel_8= fitcecoc(data_8, lable_8,'KFold',10);
            end
            classifierModel{6}=classifierModel_8;

        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        
        testLabelsPredicted_8 = kfoldPredict(classifierModel_8);
        [C,order] = confusionmat(lable_8,testLabelsPredicted_8');
        figure
        CC_8=confusionchart(C,order);
        CC_8.RowSummary = 'row-normalized';
        CC_8.ColumnSummary = 'column-normalized';

    end

    %% No Validation 
    %one classifier for each locomotion mode, the only difference from
    %10-fold mode is that here we do not have any validation
elseif ValidationMethode==""

    if ~isempty(lable_3)

        data_3=[data_3,lable_3'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_3,Testpercentage,trainpercentage, validationpercentage);
        lable_3=testdata(:,end);
        trainlabel_3=traindata(:,end);
        testdata_3=testdata(:,1:end-1);
        traindata_3=traindata(:,1:end-1);
        try
            if ClassificationMethod=="LDA"
                classifierModel{1}= fitcdiscr(traindata_3, trainlabel_3, 'DiscrimType', dType);
                for k=2:length(classifierModel{1}.Coeffs)
                  %  classifierModel{1}.Cost(k,1)=20;
                end
               

            elseif ClassificationMethod=="SVM"
                classifierModel{1}= fitcecoc(traindata_3, trainlabel_3);
            end
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        testLabelsPredicted_3 = predict(classifierModel{1}, testdata_3);



        [C,order] =confusionmat(lable_3,testLabelsPredicted_3');
        figure
        CC_3=confusionchart(C,order);
        CC_3.RowSummary = 'row-normalized';
        CC_3.ColumnSummary = 'column-normalized';
        CC_3.Title = "Walking";

    end
    if ~isempty(lable_4)

        data_4=[data_4,lable_4'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_4,Testpercentage,trainpercentage, validationpercentage);
        lable_4=testdata(:,end);
        trainlabel_4=traindata(:,end);
        testdata_4=testdata(:,1:end-1);
        traindata_4=traindata(:,1:end-1);
        try
            if ClassificationMethod=="LDA"
                classifierModel{2}= fitcdiscr(traindata_4, trainlabel_4, 'DiscrimType', dType);
                if length(classifierModel{2}.Cost)>1
                 %   classifierModel{2}.Cost(2,1)=20;
                end
            elseif ClassificationMethod=="SVM"
                classifierModel{2}= fitcecoc(traindata_4, trainlabel_4);
            end
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        testLabelsPredicted_4 = predict(classifierModel{2}, testdata_4);



        [C,order] =confusionmat(lable_4,testLabelsPredicted_4');
        figure
        CC_4=confusionchart(C,order);
        CC_4.RowSummary = 'row-normalized';
        CC_4.ColumnSummary = 'column-normalized';
        CC_4.Title = "RampA";
    end
    if ~isempty(lable_5)
        data_5=[data_5,lable_5'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_5,Testpercentage,trainpercentage, validationpercentage);
        lable_5=testdata(:,end);
        trainlabel_5=traindata(:,end);
        testdata_5=testdata(:,1:end-1);
        traindata_5=traindata(:,1:end-1);
        try
            if ClassificationMethod=="LDA"
                classifierModel{3}= fitcdiscr(traindata_5, trainlabel_5, 'DiscrimType', dType);
                if length(classifierModel{3}.Cost)>1
                 %   classifierModel{3}.Cost(2,1)=20;
                end
            elseif ClassificationMethod=="SVM"
                classifierModel{3}= fitcecoc(traindata_5, trainlabel_5);
            end

        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        testLabelsPredicted_5 = predict(classifierModel{3}, testdata_5);


        [C,order] =confusionmat(lable_5,testLabelsPredicted_5');
        figure
        CC_5=confusionchart(C,order);
        CC_5.RowSummary = 'row-normalized';
        CC_5.ColumnSummary = 'column-normalized';
        CC_5.Title = "RampD";
    end
    if ~isempty(lable_6)
        data_6=[data_6,lable_6'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_6,Testpercentage,trainpercentage, validationpercentage);
        lable_6=testdata(:,end);
        trainlabel_6=traindata(:,end);
        testdata_6=testdata(:,1:end-1);
        traindata_6=traindata(:,1:end-1);
        try
            if ClassificationMethod=="LDA"
                classifierModel{4}= fitcdiscr(traindata_6, trainlabel_6, 'DiscrimType', dType);
                if length(classifierModel{4}.Cost)>1
                  %  classifierModel{4}.Cost(2,1)=20;
                end
            elseif ClassificationMethod=="SVM"
                classifierModel{4}= fitcecoc(traindata_6, trainlabel_6);
            end
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        testLabelsPredicted_6 = predict(classifierModel{4}, testdata_6);



        [C,order] =confusionmat(lable_6,testLabelsPredicted_6');
        figure
        CC_6=confusionchart(C,order);
        CC_6.RowSummary = 'row-normalized';
        CC_6.ColumnSummary = 'column-normalized';
        CC_6.Title = "StairA";
    end
    if ~isempty(lable_7)
        data_7=[data_7,lable_7'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_7,Testpercentage,trainpercentage, validationpercentage);
        lable_7=testdata(:,end);
        trainlabel_7=traindata(:,end);
        testdata_7=testdata(:,1:end-1);
        traindata_7=traindata(:,1:end-1);
        try
            if ClassificationMethod=="LDA"
                classifierModel{5}= fitcdiscr(traindata_7, trainlabel_7, 'DiscrimType', dType);
                if length(classifierModel{5}.Cost)>1
                   % classifierModel{5}.Cost(2,1)=20;
                end
            elseif ClassificationMethod=="SVM"
                classifierModel{5}= fitcecoc(traindata_7, trainlabel_7);
            end
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        testLabelsPredicted_7 = predict(classifierModel{5}, testdata_7);



        [C,order] =confusionmat(lable_7,testLabelsPredicted_7');
        figure
        CC_7=confusionchart(C,order);
        CC_7.RowSummary = 'row-normalized';
        CC_7.ColumnSummary = 'column-normalized';
        CC_7.Title = "StairD";

    end
    if ~isempty(lable_8) && length(lable_8)>5
        data_8=[data_8,lable_8'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_8,Testpercentage,trainpercentage, validationpercentage);
        lable_8=testdata(:,end);
        trainlabel_8=traindata(:,end);
        testdata_8=testdata(:,1:end-1);
        traindata_8=traindata(:,1:end-1);
        try
            if ClassificationMethod=="LDA"
                classifierModel{6}= fitcdiscr(traindata_8, trainlabel_8, 'DiscrimType', dType);
                if length(classifierModel{6}.Cost)>1
                    classifierModel{6}.Cost(2,1)=20;
                end
            elseif ClassificationMethod=="SVM"
                classifierModel{6}= fitcecoc(traindata_8, trainlabel_8);
            end
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        testLabelsPredicted_8 = predict(classifierModel{6}, testdata_8);



        [C,order] =confusionmat(lable_8,testLabelsPredicted_8');
        figure
        CC_8=confusionchart(C,order);
        CC_8.RowSummary = 'row-normalized';
        CC_8.ColumnSummary = 'column-normalized';
        CC_8.Title = "";
    end
end


testLabelsPredicted=[];
end