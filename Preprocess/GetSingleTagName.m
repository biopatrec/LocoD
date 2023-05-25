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