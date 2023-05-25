try
    Func1()
catch Ex
    gprlog('* Got exception: %s', GetExceptionSummary(Ex))
end

function Func1()
    Func2()
end

function Func2()
    Func3()
end

function Func3()
    Func4()
end

function Func4()
    A = 0 / 'test';
end
