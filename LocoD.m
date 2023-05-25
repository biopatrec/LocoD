
clear all

disp('LocoD entrypoint')

thisScriptPath = mfilename('fullpath');
if ~isempty(thisScriptPath)
    thisScriptPath = replace(thisScriptPath, '/', '\');
    [thisScriptDir,~,~] = fileparts(thisScriptPath);

    curPath = split(path, ';');

    % Get all path directories not related to LocoD
    newPath = {};
    for pathElemN = 1:length(curPath)
        pathElem = curPath{pathElemN};
        if ~startsWith(pathElem, thisScriptDir)
            newPath{end + 1, 1} = pathElem;
        end
    end

    %disp(newPath)

    % Add LocoD and all first level subdirectories to path
    items = dir(thisScriptDir);
    additionalPath = {};
    for i = 1 : length(items)
        if ~items(i).isdir || items(i).name(1) == '.'
            % Not directory or . or .. or hidden directory (.git, .svn,
            % etc.)
            continue
        end
        if strcmpi(items(i).name, 'Old versions')
            % Exclude
            continue
        end
        additionalPath{end + 1, 1} = [thisScriptDir '\' items(i).name];
    end

    % Add additional paths to path (note: put in the beginning).
    newPath = [thisScriptDir; additionalPath; newPath];
    newPath = join(newPath, ';');
    newPath = newPath{1};
    path(newPath);
end

clear all
close all

% We close all windows and destroy all timers on
%   entry point of the main GUI.

GUI_LocoD()
