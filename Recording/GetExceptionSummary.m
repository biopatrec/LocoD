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

