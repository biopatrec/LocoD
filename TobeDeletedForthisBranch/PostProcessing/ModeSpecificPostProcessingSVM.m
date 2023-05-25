%Mode specific processing

function [testLabelsPredicted,classifierModel,CC_3,CC_4,CC_5,CC_6,CC_7]= ModeSpecificPostProcessingSVM(data,Lables,Prevlabel, PostProcessing,PostProcessingThreshold,Validation,Testpercentage,trainpercentage, validationpercentage)
tg_3=1; tg_4=1; tg_5=1; tg_6=1; tg_7=1; tg_8=1; tg_9=1;
lable_8=0;
CC_3=[];CC_4=[];CC_5=[];CC_6=[];CC_7=[];CC_8=[];CC_9=[];

classifierModel={};
lable_3=[];lable_4=[];lable_5=[];lable_6=[];lable_7=[];lable_8=[];
dType= 'pseudolinear';


%% Categorize data
for i=1:length(Prevlabel)
    if (Prevlabel(i)==3 ||   floor(Prevlabel(i) /10)==3)  && (Lables(i) == 3 || Lables(i) == 34 || Lables(i) == 35 || Lables(i) == 36 || Lables(i) == 37 || Lables(i) == 38 || Lables(i) == 39)
        % 3 (walking) can have transition to all the movments so if the
        % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
        % 39
        % I have to make classifier with these data in it
        lable_3(tg_3) = Lables(i);
        data_3(tg_3,:) = data(i,:);
        tg_3=tg_3+1;

    elseif (Prevlabel(i)==4  ||   floor(Prevlabel(i) /10)==4)  && (Lables(i) == 4 || Lables(i) == 43 || Lables(i) == 48)
        lable_4(tg_4) = Lables(i);
        data_4(tg_4,:) = data(i,:);
        tg_4=tg_4+1;
        %This is a bit tricky how to categorize transition

    elseif (Prevlabel(i)==5  ||   floor(Prevlabel(i) /10)==5) && (Lables(i) == 5 || Lables(i) == 53 || Lables(i) == 58)
        lable_5(tg_5) = Lables(i);
        data_5(tg_5,:) = data(i,:);
        tg_5=tg_5+1;


    elseif (Prevlabel(i)==6  ||   floor(Prevlabel(i) /10)==6)  && (Lables(i) == 6 || Lables(i) == 63 || Lables(i) == 68)
        lable_6(tg_6) = Lables(i);
        data_6(tg_6,:) = data(i,:);
        tg_6=tg_6+1;

    elseif (Prevlabel(i)==7  ||   floor(Prevlabel(i) /10)==7)  && (Lables(i) == 7 || Lables(i) == 73 || Lables(i) == 78)
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

if Validation==1
    if ~isempty(lable_3)
        try
            
            classifierModel_3 = fitcecoc(data_3, lable_3,'KFold',10);
            classifierModel{1}=classifierModel_3;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        %Prediction
        [testLabelsPredictedNoPP_3,Score_3,~] = kfoldPredict(classifierModel_3);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection=Score_3>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels=LableWithRejection(any(LableWithRejection,2),:);
            lable_3=lable_3(:,any(LableWithRejection,2));
            if ~isempty(ZeroRemovedLabels)
                for j=1:length(ZeroRemovedLabels)
                    %Assign Lables to them based on class name
                    testLabelsPredicted_3(j)=classifierModel_3.ClassNames(find(ZeroRemovedLabels(j,:)));
                end
            else
                testLabelsPredicted_3=testLabelsPredictedNoPP_3;
            end
        else
            testLabelsPredicted_3=testLabelsPredictedNoPP_3;
        end
        %Find Accuracy:

        [C,order] =confusionmat(lable_3,testLabelsPredicted_3');
        figure
        CC_3=confusionchart(C,order);
        CC_3.RowSummary = 'row-normalized';
        CC_3.ColumnSummary = 'column-normalized';
        CC_3.Title = "Walking";
    end
    if ~isempty(lable_4)
        try
            classifierModel_4 = fitcecoc(data_4, lable_4,'KFold',10);
            classifierModel{2}=classifierModel_4;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        %Prediction
        [testLabelsPredictedNoPP_4,Score_4,~] = kfoldPredict(classifierModel_4);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_4=Score_4>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_4=LableWithRejection_4(any(LableWithRejection_4,2),:);
            lable_4=lable_4(:,any(LableWithRejection_4,2));
            if ~isempty(ZeroRemovedLabels_4)
                for j=1:length(ZeroRemovedLabels_4)
                    %Assign Lables to them based on class name
                    testLabelsPredicted_4(j)=classifierModel_4.ClassNames(find(ZeroRemovedLabels_4(j,:)));
                end
            else
                testLabelsPredicted_4=testLabelsPredictedNoPP_4;
            end
        else
            testLabelsPredicted_4=testLabelsPredictedNoPP_4;
        end
        %Find Accuracy:

        [C,order] =confusionmat(lable_4,testLabelsPredicted_4');
        figure
        CC_4=confusionchart(C,order);
        CC_4.RowSummary = 'row-normalized';
        CC_4.ColumnSummary = 'column-normalized';
        CC_4.Title = "RampA";

    end
    if ~isempty(lable_5)
        try

            classifierModel_5 = fitcecoc(data_5, lable_5,'KFold',10);
            classifierModel{3}=classifierModel_5;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        %Prediction
        [testLabelsPredictedNoPP_5,Score_5,~] = kfoldPredict(classifierModel_5);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_5=Score_5>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_5=LableWithRejection_5(any(LableWithRejection_5,2),:);
            lable_5=lable_5(:,any(LableWithRejection_5,2));
            if ~isempty(ZeroRemovedLabels_5)
                for j=1:length(ZeroRemovedLabels_5)
                    %Assign Lables to them based on class name
                    testLabelsPredicted_5(j)=classifierModel_5.ClassNames(find(ZeroRemovedLabels_5(j,:)));
                end
            else
                testLabelsPredicted_5=testLabelsPredictedNoPP_5;
            end
        else
            testLabelsPredicted_5=testLabelsPredictedNoPP_5;
        end
        %Find Accuracy:

        [C,order] =confusionmat(lable_5,testLabelsPredicted_5');
        figure
        CC_5=confusionchart(C,order);
        CC_5.RowSummary = 'row-normalized';
        CC_5.ColumnSummary = 'column-normalized';
        CC_5.Title = "RampD";
    end
    if ~isempty(lable_6)
        try

            classifierModel_6 = fitcecoc(data_6, lable_6,'KFold',10);


            classifierModel{4}=classifierModel_6;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        %Prediction
        [testLabelsPredictedNoPP_6,Score_6,~] = kfoldPredict(classifierModel_6);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_6=Score_6>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_6=LableWithRejection_6(any(LableWithRejection_6,2),:);
            lable_6=lable_6(:,any(LableWithRejection_6,2));
            if ~isempty(ZeroRemovedLabels_6)
                for j=1:length(ZeroRemovedLabels_6)
                    %Assign Lables to them based on class name
                    testLabelsPredicted_6(j)=classifierModel_6.ClassNames(find(ZeroRemovedLabels_6(j,:)));
                end
            else
                testLabelsPredicted_6=testLabelsPredictedNoPP_6;
            end
        else
            testLabelsPredicted_6=testLabelsPredictedNoPP_6;
        end
        %Find Accuracy:

        [C,order] =confusionmat(lable_6,testLabelsPredicted_6');
        figure
        CC_6=confusionchart(C,order);
        CC_6.RowSummary = 'row-normalized';
        CC_6.ColumnSummary = 'column-normalized';
        CC_6.Title = "StairA";

    end
    if ~isempty(lable_7)
        try

            classifierModel_7 = fitcecoc(data_7, lable_7,'KFold',10);

            classifierModel{5}=classifierModel_7;
        catch e
            disp(e)
            errordlg(e.message);
            return;
        end
        %Prediction
        [testLabelsPredictedNoPP_7,Score_7,~] = kfoldPredict(classifierModel_7);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_7=Score_7>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_7=LableWithRejection_7(any(LableWithRejection_7,2),:);
            lable_7=lable_7(:,any(LableWithRejection_7,2));
            if ~isempty(ZeroRemovedLabels_7)
            for j=1:length(ZeroRemovedLabels_7)
                %Assign Lables to them based on class name
                testLabelsPredicted_7(j)=classifierModel_7.ClassNames(find(ZeroRemovedLabels_7(j,:)));
            end
            else
                testLabelsPredicted_7=testLabelsPredictedNoPP_7;
            end
        else
            testLabelsPredicted_7=testLabelsPredictedNoPP_7;
        end
        %Find Accuracy:

        [C,order] = confusionmat(lable_7,testLabelsPredicted_7');
        figure
        CC_7=confusionchart(C,order);
        CC_7.RowSummary = 'row-normalized';
        CC_7.ColumnSummary = 'column-normalized';
        CC_7.Title = "StairD";
    end
elseif Validation==0
    if ~isempty(lable_3)

        data_3=[data_3,lable_3'];
        [testdata,traindata,validationdata]=TestTrainValidSeperator(data_3,Testpercentage,trainpercentage, validationpercentage);
        lable_3=testdata(:,end);
        trainlabel_3=traindata(:,end);
        testdata_3=testdata(:,1:end-1);
        traindata_3=traindata(:,1:end-1);
        try
            classifierModel_3= fitcecoc(traindata_3, trainlabel_3, 'DiscrimType', dType);
            classifierModel{1}=classifierModel_3;
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        [testLabelsPredictedNoPP_3,Score_3,~] = predict(classifierModel{1}, testdata_3);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_3=Score_3>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_3=LableWithRejection_3(any(LableWithRejection_3,2),:);
            lable_3=lable_3(any(LableWithRejection_3,2));
            for j=1:length(ZeroRemovedLabels_3)
                %Assign Lables to them based on class name
                testLabelsPredicted_3(j)=classifierModel_3.ClassNames(find(ZeroRemovedLabels_3(j,:)));
            end
        else
            testLabelsPredicted_3=testLabelsPredictedNoPP_3;
        end
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
            classifierModel_4= fitcecoc(traindata_4, trainlabel_4, 'DiscrimType', dType);
            classifierModel{2}=classifierModel_4;
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end

        [testLabelsPredictedNoPP_4,Score_4,~] = predict(classifierModel{2}, testdata_4);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_4=Score_4>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_4=LableWithRejection_4(any(LableWithRejection_4,2),:);
            lable_4=lable_4(any(LableWithRejection_4,2));
            for j=1:length(ZeroRemovedLabels_4)
                %Assign Lables to them based on class name
                testLabelsPredicted_4(j)=classifierModel_4.ClassNames(find(ZeroRemovedLabels_4(j,:)));
            end
        else
            testLabelsPredicted_4=testLabelsPredictedNoPP_4;
        end

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
            classifierModel_5= fitcecoc(traindata_5, trainlabel_5, 'DiscrimType', dType);
            classifierModel{3}=classifierModel_5;
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        [testLabelsPredictedNoPP_5,Score_5,~] = predict(classifierModel{3}, testdata_5);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_5=Score_5>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_5=LableWithRejection_5(any(LableWithRejection_5,2),:);
            lable_5=lable_5(any(LableWithRejection_5,2));
            for j=1:length(ZeroRemovedLabels_5)
                %Assign Lables to them based on class name
                testLabelsPredicted_5(j)=classifierModel_5.ClassNames(find(ZeroRemovedLabels_5(j,:)));
            end
        else
            testLabelsPredicted_5=testLabelsPredictedNoPP_5;
        end
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
            classifierModel_6= fitcecoc(traindata_6, trainlabel_6, 'DiscrimType', dType);
            classifierModel{4}=classifierModel_6;
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        [testLabelsPredictedNoPP_6,Score_6,~] = predict(classifierModel{4}, testdata_6);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_6=Score_6>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_6=LableWithRejection_6(any(LableWithRejection_6,2),:);
            lable_6=lable_6(any(LableWithRejection_6,2));
            for j=1:length(ZeroRemovedLabels_6)
                %Assign Lables to them based on class name
                testLabelsPredicted_6(j)=classifierModel_6.ClassNames(find(ZeroRemovedLabels_6(j,:)));
            end
        else
            testLabelsPredicted_6=testLabelsPredictedNoPP_6;
        end
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
            classifierModel_7= fitcecoc(traindata_7, trainlabel_7, 'DiscrimType', dType);
            classifierModel{5}=classifierModel_7;
        catch e
            disp(e)
            errordlg(e.message);
            accVset = [];
            coeff = [];
            return;
        end
        [testLabelsPredictedNoPP_7,Score_7,~] = predict(classifierModel{5}, testdata_7);
        % Post Processing
        if PostProcessing==1  %If we want to the rejection
            LableWithRejection_7=Score_7>PostProcessingThreshold;
            %Remove rows in predicted and in target lables that are zero in
            %predicted
            ZeroRemovedLabels_7=LableWithRejection_7(any(LableWithRejection_7,2),:);
            lable_7=lable_7(any(LableWithRejection_7,2));
            for j=1:length(ZeroRemovedLabels_7)
                %Assign Lables to them based on class name
                testLabelsPredicted_7(j)=classifierModel_7.ClassNames(find(ZeroRemovedLabels_7(j,:)));
            end
        else
            testLabelsPredicted_7=testLabelsPredictedNoPP_7;
        end
        [C,order] =confusionmat(lable_7,testLabelsPredicted_7');
        figure
        CC_7=confusionchart(C,order);
        CC_7.RowSummary = 'row-normalized';
        CC_7.ColumnSummary = 'column-normalized';
        CC_7.Title = "StairD";
    end
end
testLabelsPredicted=[];
end