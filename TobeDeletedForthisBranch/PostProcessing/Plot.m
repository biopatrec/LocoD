close all;
Thresh=[0.989 0.987 0.985 0.98 0.97 0.95 0.9 0.85 0.8 0.75 0.7 0.65] ;
Diff=[ 2.94 2.76 2.73 2.640301573 2.39 2.132001586 1.614046564 1.177023539 0.9623607 0.899340894 0.769959435 0.6122] ;
Rej_Percentage = [7 6.15 5.9683887 5.440726721 4.7621 3.95 2.88 2.37 1.76 1.4 1.09 0.96];

figure;
plot(Thresh,Diff,'k-o','LineWidth',1.8);
xlabel('Rejection Threshold','FontSize', 18)
ylabel('Classification accuracy difference (%)','FontSize', 18)
title ('Accuracy Improvement With Post-Processing')

set(gca,'FontSize',17)
grid on

figure;
plot(Thresh,Rej_Percentage,'k-o','LineWidth',1.8)
xlabel('Rejection Threshold','FontSize', 16)
ylabel('Percent of Rejected Windows','FontSize', 16)
set(gca,'FontSize',17)
grid on


All_NoPP= 100-[0.9816 0.9700 0.9429 0.9567 0.9791 0.8472 0.9738 0.9444 0.9412 0.9563 0.8716 0.9466 0.9066 0.9605 0.9202 0.9405 0.8947 0.9624 0.8682 0.9799 0.9335]*100;


All_PP=100- [0.989591694 0.980349309 0.968534183 0.97472052 0.986898342 0.908524165 0.988044589 0.973679639 0.966937005 0.974927013 0.944395767 0.96931071 0.971315317 0.984695179 0.921856447 0.968331941 0.944192287 0.980837319 0.933048461 0.993005353 0.971906302]*100;

All=[All_NoPP;All_PP];


x= 1:21;
figure
b=bar(x,All,'FaceColor', 'k');
xlabel('Number of Participants','FontSize', 20)
ylabel('Locomotion detection Error','FontSize', 20)
legend('Without post-processing','With post-processing','FontSize', 18)
set(gca,'FontSize',17)
grid on




