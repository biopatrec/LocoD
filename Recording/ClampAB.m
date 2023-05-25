%Clamp a signal between given max an min
function y = ClampAB(x, Max, Min)
    if Max < Min
        t = Max;
        Max = Min;
        Min = t;
    end
    if x > Max
        y = Max;
    elseif x < Min
        y = Min;
    else
        y = x;
    end
end