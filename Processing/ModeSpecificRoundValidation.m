function [testLabelsPredicted,classifierModel]= ModeSpecificRoundValidation(data,Lables,Prevlabel, ValidationMethode,dType)
tg_3=1; tg_4=1; tg_5=1; tg_6=1; tg_7=1; tg_8=1; tg_9=1;
lable_8=0;



for r=1:length(data)
    testdata
    testLabels
    traindata
    trainLables
    Prevlabel

for i=1:length(Prevlabel)
    if (Prevlabel(i)==3 || floor(Prevlabel(i)/10)==3)  && (Lables(i) == 3 || Lables(i) == 34 || Lables(i) == 35 || Lables(i) == 36 || Lables(i) == 37 || Lables(i) == 38 || Lables(i) == 39)
        % 3 (walking) can have transition to all the movments so if the
        % one before is 3 it can be 3 or 34 or 35 or 36 or 36 or 38 or
        % 39
        % I have to make classifier with these data in it
        lable_3(tg_3) = Lables(i);
        data_3(tg_3,:) = data(i,:);
        tg_3=tg_3+1;

    elseif (Prevlabel(i)==4  || floor(Prevlabel(i)/10)==4)  && (Lables(i) == 4 || Lables(i) == 43 || Lables(i) == 48)
        lable_4(tg_4) = Lables(i);
        data_4(tg_4,:) = data(i,:);
        tg_4=tg_4+1;
        %This is a bit tricky how to categorize transition

    elseif (Prevlabel(i)==5  || floor(Prevlabel(i)/10)==5) && (Lables(i) == 5 || Lables(i) == 53 || Lables(i) == 58)
        lable_5(tg_5) = Lables(i);
        data_5(tg_5,:) = data(i,:);
        tg_5=tg_5+1;


    elseif (Prevlabel(i)==6  || floor(Prevlabel(i)/10)==6)  && (Lables(i) == 6 || Lables(i) == 63 || Lables(i) == 68)
        lable_6(tg_6) = Lables(i);
        data_6(tg_6,:) = data(i,:);
        tg_6=tg_6+1;

    elseif (Prevlabel(i)==7  || floor(Prevlabel(i)/10)==7)  && (Lables(i) == 7 || Lables(i) == 73 || Lables(i) == 78)
        lable_7(tg_7) = Lables(i);
        data_7(tg_7,:) = data(i,:);
        tg_7=tg_7+1;


    elseif (Prevlabel(i)==8  || floor(Prevlabel(i)/10)==8)  && (Lables(i) == 8 || Lables(i) == 83 || Lables(i) == 84 || Lables(i) == 85  || Lables(i) == 86 || Lables(i) == 87)
        lable_8(tg_8) = Lables(i);
        data_8(tg_8,:) = data(i,:);
        tg_8=tg_8+1;

    elseif (Prevlabel(i)==9  || floor(Prevlabel(i)/10)==9)



    end
end

if ~isempty(lable_3)
    try

        %classifierModel = fitcdiscr(data_3, lable_3,'Leaveout','on', 'DiscrimType', dType);
        classifierModel = fitcdiscr(data_3, lable_3,'KFold',200, 'DiscrimType', dType);


    catch e
        disp(e)
        errordlg(e.message);
        return;
    end

    testLabelsPredicted_3 = kfoldPredict(classifierModel);
    [C,order] =confusionmat(lable_3,testLabelsPredicted_3');
    figure
    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    CC.Title = "Walking";

end
if ~isempty(lable_4)
    try
        % classifierModel_4 = fitcdiscr(data_4, lable_4,'Leaveout','on', 'DiscrimType', dType);
        classifierModel_4 = fitcdiscr(data_4, lable_4,'KFold',200, 'DiscrimType', dType);

    catch e
        disp(e)
        errordlg(e.message);
        return;
    end

    testLabelsPredicted_4 = kfoldPredict(classifierModel_4);
    [C,order] =confusionmat(lable_4,testLabelsPredicted_4');
    figure
    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    CC.Title = "RampA";

end
if ~isempty(lable_5)
    try
        % classifierModel_5 = fitcdiscr(data_5, lable_5,'Leaveout','on', 'DiscrimType', dType);
        classifierModel_5 = fitcdiscr(data_5, lable_5,'KFold',200, 'DiscrimType', dType);

    catch e
        disp(e)
        errordlg(e.message);
        return;
    end

    testLabelsPredicted_5 = kfoldPredict(classifierModel_5);
    [C,order] =confusionmat(lable_5,testLabelsPredicted_5');
    figure
    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    CC.Title = "RampD";
end
if ~isempty(lable_6)
    try
        % classifierModel_6 = fitcdiscr(data_6, lable_6,'Leaveout','on', 'DiscrimType', dType);
        classifierModel_6 = fitcdiscr(data_6, lable_6,'KFold',200, 'DiscrimType', dType);
    catch e
        disp(e)
        errordlg(e.message);
        return;
    end

    testLabelsPredicted_6 = kfoldPredict(classifierModel_6);
    [C,order] =confusionmat(lable_6,testLabelsPredicted_6');
    figure
    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    CC.Title = "StairA";

end
if ~isempty(lable_7)
    try
        %  classifierModel_7 = fitcdiscr(data_7, lable_7,'Leaveout','on', 'DiscrimType', dType);
        classifierModel_7 = fitcdiscr(data_7, lable_7,'KFold',5, 'DiscrimType', dType);
    catch e
        disp(e)
        errordlg(e.message);
        return;
    end

    testLabelsPredicted_7 = kfoldPredict(classifierModel_7);
    [C,order] = confusionmat(lable_7,testLabelsPredicted_7');
    figure
    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';
    CC.Title = "StairD";

end
if ~isempty(lable_8) && length(lable_8)>5
    try
        % classifierModel_8 = fitcdiscr(data_8, lable_8,'Leaveout','on', 'DiscrimType', dType);
        classifierModel_8 = fitcdiscr(data_8, lable_8,'KFold',200, 'DiscrimType', dType);

    catch e
        disp(e)
        errordlg(e.message);
        return;
    end

    testLabelsPredicted_8 = kfoldPredict(classifierModel_8);
    [C,order] = confusionmat(lable_8,testLabelsPredicted_8');
    figure
    CC=confusionchart(C,order);
    CC.RowSummary = 'row-normalized';
    CC.ColumnSummary = 'column-normalized';

end

end
testLabelsPredicted=[];
end