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
%Convert times string HMS to seconds
% --------------------------Updates--------------------------
% 2022-03-15 / Bahareh Ahkami / Creation
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

