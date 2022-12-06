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
%Get tag names to save in a file as an agenda or to show in the
%classification result
% --------------------------Updates--------------------------




function [tagname, transitionTo]=GetTagName(tagid,steadytag)


if tagid< 10  %Steady modes
    tagname=GetSingleTagName(tagid);
    transitionTo=tagname;
elseif tagid==1000 %Transition
    tagname=GetSingleTagName(tagid);
    transitionTo=steadytag;
elseif tagid==-1000 %Steady means no transition, so the tag will be the tag before
    tagname=GetSingleTagName(tagid);
    transitionTo=steadytag;
elseif tagid> 10
    transitionTo  = mod(tagid, 10);
    tag_before = floor(tagid/ 10);
    tagname_before = GetSingleTagName(tag_before);
    transitionTo= GetSingleTagName(transitionTo);
    tagname=tagname_before + "_to_" + transitionTo;
else
    tagid=3;
    tagname=GetSingleTagName(tagid);
    transitionTo=tagname;
    %error("Wrong Tag %s",tagid);
end


end
