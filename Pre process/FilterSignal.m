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
% Filter the signal with 
% Any kind of Filter can be added to this file
% --------------------------Updates--------------------------


function FilteredSignal=FilterSignal(sf,data,filtertype,chidx)
%% Filter Signal
FilteredSignal=data;
if filtertype=="Notch 50 HZ"
    %Notch
    N   = 6;  % Order
    Fc1 = 49;  % First Cutoff Frequency
    Fc2 = 51;  % Second Cutoff Frequency

    [z,p,k] = butter(N/2, [Fc1 Fc2]/(sf/2), 'stop');

    [sos_var,g] = zp2sos(z, p, k);
    Hd50        = dfilt.df2sos(sos_var, g);
    FilteredSignal(chidx,:) = filter(Hd50,data(chidx,:),2);
elseif filtertype=="20- 500 HZ"
    % Bandpass filter
    N   = 4;     % Order
    FC1=20;
    FC2=500;

    % Calculate the zpk values using the BUTTER function.
    [z,p,k] = butter(N/2, [FC1 FC2]/(sf/2));

    [sos_var,g] = zp2sos(z, p, k);
    Hd          = dfilt.df2sos(sos_var, g);
    FilteredSignal(chidx,:) = filter(Hd,data(chidx,:),2);
elseif filtertype=="None"
    FilteredSignal=data;
elseif filtertype =="0- 50 HZ"
    % Bandpass filter
    N   = 4;     % Order
    FC1=1;
    FC2=50;

    % Calculate the zpk values using the BUTTER function.
    [z,p,k] = butter(N/2, [FC1 FC2]/(sf/2));

    [sos_var,g] = zp2sos(z, p, k);
    Hd          = dfilt.df2sos(sos_var, g);
    FilteredSignal(chidx,:) = filter(Hd,data(chidx,:),2);

else
    gprlog("*Invalid filtertype")
    error("Invalid filtertype")
end
end