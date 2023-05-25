%Convert times string HMS to seconds
function t = TimeStringToSeconds(str)
    try
        parts = str2double(strsplit(str, ':'));
        H = 0;
        M = 0;
        multipart = 0;
        
        if length(parts) >= 3
            H = parts(end - 2);
        end
        if length(parts) >= 2
            M = parts(end - 1);
            multipart = 1;
        end
        S = parts(end);

        % Handle invalid values, as well as NaN, inf, etc.
        if length(parts) > 3 || ...
            ~(H >= 0) || ~(M >= 0 && M < 60) || ...
            (~multipart && ~(S >= 0)) || ...
            (multipart && ~(S >= 0 && S < 60))
            throw(MException("LOCOD:InvalidTimeString", "-"));
        end

        t = H * 3600 + M * 60 + S;
    catch Ex
        throw(MException("LOCOD:InvalidTimeString", "Cannot understand input " + str));
    end
end

