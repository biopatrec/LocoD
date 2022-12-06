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
% This is LocoD Entry Point
%
% --------------------------Updates--------------------------

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
