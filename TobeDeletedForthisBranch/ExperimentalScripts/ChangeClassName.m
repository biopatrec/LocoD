folderPath = 'U:\LLP\LocoD-Github\TestCodes';  % Specify the folder path containing your MATLAB files
oldClassName = 'SignalAcuired';  % Specify the old class name to be replaced
newClassName = 'Signal';  % Specify the new class name
%Signal, Signalsacquired, Processing, Decoding
% Get a list  of all MATLAB files in the folder
fileList = dir(fullfile(folderPath, '*.m'));

% Iterate over each file in the folder
for i = 1:numel(fileList)
    filePath = fullfile(folderPath, fileList(i).name);
    
    % Read the content of the file
    fileContent = fileread(filePath);
    
    % Perform the search and replace operation
    modifiedContent = replace(fileContent, oldClassName, newClassName);
    
    % Write the modified content back to the file
    fid = fopen(filePath, 'w');
    fprintf(fid, '%s', modifiedContent);
    fclose(fid);
end

disp('Search and replace operation completed.');