
close all
clear all

figure;
f = gca;
STEP = 0;

for t = (0:1000)
    pause(0.1);
    T = (t-500:0.1:t);
    nT = length(T);
    if STEP == 0
        hold(f, 'off');
        plot(f, T / 100, randn(1, nT) * 0.4);
        hold(f, 'on')
        plot(f, T / 100, randn(1, nT) * 0.3 + 3);
        xlim(f, [t/100 - 5, t/100]);
        ylim(f, [-5, 5]);
        hold(f, 'on')
        %xline(f, (rand(1,3) * (max(T) - min(T)) + min(T)) / 100)

        STEP = 1;
    else
        f.Children(1).XData = T / 100;
        f.Children(1).YData = randn(1, nT) * 0.4;
        f.Children(2).XData = T / 100;
        f.Children(2).YData = randn(1, nT) * 0.3 + 3;
        %drawnow limitrate nocallbacks
    end

    f = gca;
    f.Interactions = [];
    f.Toolbar.Visible = 'off';
    disableDefaultInteractivity(f)

end
