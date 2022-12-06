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
% Get Exception
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation
function text = GetExceptionSummary(ex)
    depth = length(ex.stack);
    depthToShow = depth;
    depthTruncated = 0;
    if depthToShow > 3
        depthToShow = 3;
        depthTruncated = 1;
    end
    text = sprintf('[%s] %s', ex.identifier, ex.message);
    spc = '';
    for i = 1:depthToShow
        text = [text sprintf('\n%s\\- %s:%d (%s)', spc, ex.stack(i).file, ex.stack(i).line, ex.stack(i).name)];
        spc = [spc '  '];
    end
    if depthTruncated
        text = [text sprintf('\n%s\\- ...', spc)];
    end
end

