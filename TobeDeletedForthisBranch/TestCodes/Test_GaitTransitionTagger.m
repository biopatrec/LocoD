clear all

s1 = [9 9 9 9 9 9 8 8 8 8 8 8 8 9 9 9 9 9 8 9 9 9 9 9 8 8 9 9 9 8 8 8 8 8 8 8 8 9 9 8 8 8];
fs = 4;

s2 = FindGaitTransitions(s1, fs, 0.6);

close all
plot(s1);
hold on
stem(s2(2,:), s2(1,:))
