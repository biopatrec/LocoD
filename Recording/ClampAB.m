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
%Clamp a signal between given max an min
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation
%Clamp a signal between given max an min
function y = ClampAB(x, Max, Min)
    if Max < Min
        t = Max;
        Max = Min;
        Min = t;
    end
    if x > Max
        y = Max;
    elseif x < Min
        y = Min;
    else
        y = x;
    end
end