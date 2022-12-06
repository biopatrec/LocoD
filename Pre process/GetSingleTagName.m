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
% Match tag numbers with tag name 
% --------------------------Updates--------------------------



%It will be called in get tag names
function tagname=GetSingleTagName(tagid)
if tagid==0
    tagname="Start";   %% To remove 0
elseif tagid==1
    tagname="Sit";
elseif tagid==2
    tagname="Standup";
elseif tagid==3
    tagname="Walk";
elseif tagid==4
    tagname="RampA";
elseif tagid==5
    tagname="RampD";
elseif tagid==6
    tagname="StairsA";
elseif tagid==7
    tagname="StairsD";
elseif tagid==8
    tagname="Stand/Stiff";
elseif tagid==1000
    tagname="Transition";
elseif tagid==-1000
    tagname="Steady";
end
end