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

