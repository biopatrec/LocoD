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
% Log Error message or normal message
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation
function gprlog(varargin)
    % For now
    fmt = varargin{1};
    
    if fmt(1) == '*'
        % Treat as error. Print second line of stack frame (first line is
        % here ofcourse!
        stack = dbstack;
        if length(stack) > 1
            fprintf(2, "* [LocoD at %s:%d (%s)]\n", stack(2).file, stack(2).line, stack(2).name);
        end
        fprintf(2, varargin{:});
        fprintf(2, '\n');
        
    else
        % Treat as normal message
        fprintf(varargin{:});
        fprintf('\n');
    end
end

