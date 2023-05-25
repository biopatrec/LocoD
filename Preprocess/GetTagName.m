%Get tag names to save in a file as an agenda or to show in the
%classification result
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
