function PlotDataFeaturespace(feature,lable)


% rng('default') % for reproducibility
% Y = tsne(feature,'Algorithm','exact','Distance','mahalanobis');
% subplot(2,2,1)
% gscatter(Y(:,1),Y(:,2),lable)
% title('Mahalanobis')

% rng('default') % for fair comparison
% Y = tsne(feature,'Algorithm','exact','Distance','cosine');
% %subplot(2,2,2)
% figure
% gscatter(Y(:,1),Y(:,2),lable)
% title('Cosine')

% rng('default') % for fair comparison
% Y = tsne(feature,'Algorithm','exact','Distance','chebychev');
% %subplot(2,2,3)
% figure
% gscatter(Y(:,1),Y(:,2),lable)
% title('Chebychev')
% 
% rng('default') % for fair comparison
% Y = tsne(feature,'Algorithm','exact','Distance','euclidean');
% %subplot(2,2,4)
% figure
% gscatter(Y(:,1),Y(:,2),lable)
% title('Euclidean')





% for i=1:length(lable)
% 
%     [lables_name{i,1},~]=GetTagName(lable(i));
% 
% end
% mapcaplot(feature,lables_name );

end