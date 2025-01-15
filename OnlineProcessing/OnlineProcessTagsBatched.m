
global BATCHOPERATIONS

BATCHOPERATIONS = [];
BATCHOPERATIONS.generation.A = [
    0.75
    0.8
    0.85
    0.87
    0.89
    0.91
    0.93
    0.95
    0.97
    0.99
];
BATCHOPERATIONS.generation.B = [
    
    "TF005"
];
BATCHOPERATIONS.generation.C = [
    "ProbMaj"
    "ProbMax"
    "ProbMeanMax"
    "MeanMaxProb"
];

BATCHOPERATIONS.fileNames = {};

for p1 = BATCHOPERATIONS.generation.A'
for p2 = BATCHOPERATIONS.generation.B'
for p3 = BATCHOPERATIONS.generation.C'
    fn = sprintf("PostProcessing\\%g\\%s\\%s-%s%d.mat", p1, p2, p2, p3, p1 * 100);
    BATCHOPERATIONS.fileNames = [BATCHOPERATIONS.fileNames; {fn, p1, p2, p3}];
end
end
end

disp(BATCHOPERATIONS.fileNames)
BATCHOPERATIONS.result = cell(size(BATCHOPERATIONS.fileNames, 1), 2);

for op = 1:size(BATCHOPERATIONS.fileNames, 1)
    BATCHOPERATIONS.current.idx = op;
    BATCHOPERATIONS.current.fileName = BATCHOPERATIONS.fileNames{op, 1};
    fprintf("======== Operation %d: %s ========\n", BATCHOPERATIONS.current.idx, BATCHOPERATIONS.current.fileName);
    
    try
        % Run Operation
        OnlineProcessTags
        % Note that global vars have been deleted except for BATCHOPERATIONS
    catch EXC
        warning(getReport(EXC,'extended'));
        result = struct;
        result.errorHappened = 1;
        BATCHOPERATIONS.result{BATCHOPERATIONS.current.idx, 1} = result;
        fprintf("======== Failed Operation %d: %s ========\n", BATCHOPERATIONS.current.idx, BATCHOPERATIONS.current.fileName);
        continue
    end

    % Gather info
    result = struct;
    [~, mis] = sort(locoModes);
    for mi = mis'
        result.(sprintf("onlineAccuSS_%d", locoModes(mi))) = onlineAccuSS(mi);
    end
    [~, mis] = sort(locoTrans);
    for mi = mis'
        result.(sprintf("onlineAccuTR_%d", locoTrans(mi))) = onlineAccuTR(mi);
    end
    
    result.accuTR = onlineAccuTRMean * 100;
    result.accuSS = onlineAccuSSMean * 100;
    result.accuMean = onlineaccu * 100;
    
    [~, mis] = sort(locoTrans);
    for mi = mis'
        result.(sprintf("tPred_%d", locoTrans(mi))) = round(predTimes(mi) * 1000);
    end
    result.tPredMean = round(meanPredictonTime * 1000);
    
    BATCHOPERATIONS.result{BATCHOPERATIONS.current.idx, 1} = BATCHOPERATIONS.current.fileName;
    BATCHOPERATIONS.result{BATCHOPERATIONS.current.idx, 2} = result;
    disp(result)
    
    fprintf("======== End of Operation %d: %s ========\n", BATCHOPERATIONS.current.idx, BATCHOPERATIONS.current.fileName);
end

fprintf("======== Wrap Up ========\n");
excelFileName = 'Results2.xlsx';
j=1;
for i=1: length(BATCHOPERATIONS.generation.C): length (BATCHOPERATIONS.result)
    dataSheet=struct2table(cell2mat(BATCHOPERATIONS.result(i:i+3,2)));
  
    writetable(dataSheet, excelFileName, 'Sheet', num2str(BATCHOPERATIONS.generation.A(j)), 'WriteMode', 'overwrite')
    j=j+1;
end




