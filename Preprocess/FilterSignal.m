%filter signal
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