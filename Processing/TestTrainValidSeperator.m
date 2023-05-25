%Seperate train, test and validation sets

function [testdata,traindata,validdata]=TestTrainValidSeperator(Data,testpercentage,trainpercentage, validpercentage)

numWindow=size(Data,1);
%numWindow=size(Data,3);
% I should do randomization here
[trainInd,valInd,testInd] =dividerand(numWindow,trainpercentage,validpercentage, testpercentage);
% traindata = Data(:,:,trainInd) ; 
% testdata = Data(:,:,testInd) ;
% validdata = Data(:,:,valInd) ;
traindata = Data(trainInd,:) ; 
testdata = Data(testInd,:) ;
validdata = Data(valInd,:) ;

                         

end