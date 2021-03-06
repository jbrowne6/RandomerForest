clear
close all
clc

FontSize = 14;

S1 = load('Sparse_parity_partial.mat');
S2 = load('Trunk_partial.mat');

Markers = {'o','^','+'};
Colors = get(gca,'ColorOrder');

for i = 1:length(S1.TestError) - 1
    Classifiers = fieldnames(S1.TestError{i});
    Classifiers(~ismember(Classifiers,{'rf','rerf','rerf2','frc','rr_rf'})) = [];
    for c = 1:length(Classifiers)
        TreeDepth = [];
        nNodes = [];
        nSplits = [];
        ErrorRate = [];
        p = [];
        Transformations = fieldnames(S1.TestError{i}.(Classifiers{c}));
        for t = 1:length(Transformations)
            ntrials = size(S1.TestError{i}.(Classifiers{c}).(Transformations{t}),1);
            TD = [];
            NN = [];
            NS = [];
            for trial = 1:ntrials
                BestIdx = hp_optimize(S1.OOBError{i}.(Classifiers{c}).(Transformations{t})(trial,:,end),...
                    S1.OOBAUC{i}.(Classifiers{c}).(Transformations{t})(trial,:,end));
                if length(BestIdx)>1
                    BestIdx = BestIdx(end);
                end
                TD = [TD,mean(S1.Depth{i}.(Classifiers{c}).(Transformations{t})(trial,:,BestIdx))];
                NN = [NN,mean(S1.NumNodes{i}.(Classifiers{c}).(Transformations{t})(trial,:,BestIdx))];
                NS = [NS,mean(S1.NumSplits{i}.(Classifiers{c}).(Transformations{t})(trial,:,BestIdx))];
            end
            TreeDepth = [TreeDepth,mean(TD)];
            nNodes = [nNodes,mean(NN)];
            nSplits = [nSplits,mean(NS)];
            ErrorRate = [ErrorRate,mean(S1.TestError{i}.(Classifiers{c}).(Transformations{t})(:,end))];
            p = [p,S1.dims(i)];
        end
        plot(TreeDepth,ErrorRate,Markers{i},'MarkerEdgeColor',Colors(c,:))
        hold on
    end
end

xlabel('Tree Depth')
ylabel('Error Rate')
title('Sparse Parity')
legend('RF','RerF','RerF2','F-RC','RR-RF','Location','southeast')
ax = gca;
ax.YScale = 'log';
ax.FontSize = FontSize;

% gscatter(TreeDepth,ErrorRate,p)
% xlabel('Tree Depth')
% ylabel('Error Rate')
% title('Sparse parity')
% legend('p = 2','p = 5','Location','southeast')
% ax = gca;
% ax.YScale = 'log';
% ax.FontSize = FontSize;
% 
save_fig(gcf,'~/RandomerForest/Figures/Sparse_parity_error_vs_depth')
% 
% figure;
% 
% gscatter(nNodes,ErrorRate,p)
% xlabel('# of nodes')
% ylabel('Error Rate')
% title('Sparse Parity')
% legend('p = 2','p = 5','Location','southeast')
% ax = gca;
% ax.YScale = 'log';
% ax.FontSize = FontSize;
% 
% save_fig(gcf,'~/RandomerForest/Figures/Sparse_parity_error_vs_num_nodes')
% 
% figure;
% 
% gscatter(nSplits,ErrorRate,p)
% xlabel('# of splits')
% ylabel('Error Rate')
% title('Sparse parity')
% legend('p = 2','p = 5','Location','southeast')
% ax = gca;
% ax.YScale = 'log';
% ax.FontSize = FontSize;
% 
% save_fig(gcf,'~/RandomerForest/Figures/Sparse_parity_error_vs_num_splits')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TreeDepth = [];
nNodes = [];
nSplits = [];
ErrorRate = [];
p = [];
figure;
for i = 1:length(S2.TestError) - 2
    Classifiers = fieldnames(S2.TestError{i});
    Classifiers(~ismember(Classifiers,{'rf','rerf','rerf2','frc','rr_rf'})) = [];
    for c = 1:length(Classifiers)
        TreeDepth = [];
        nNodes = [];
        nSplits = [];
        ErrorRate = [];
        p = [];
        Transformations = fieldnames(S2.TestError{i}.(Classifiers{c}));
        for t = 1:length(Transformations)
            ntrials = size(S2.TestError{i}.(Classifiers{c}).(Transformations{t}),1);
            TD = [];
            NN = [];
            NS = [];
            for trial = 1:ntrials
                BestIdx = hp_optimize(S2.OOBError{i}.(Classifiers{c}).(Transformations{t})(trial,:,end),...
                    S2.OOBAUC{i}.(Classifiers{c}).(Transformations{t})(trial,:,end));
                if length(BestIdx)>1
                    BestIdx = BestIdx(end);
                end
                TD = [TD,mean(S2.Depth{i}.(Classifiers{c}).(Transformations{t})(trial,:,BestIdx))];
                NN = [NN,mean(S2.NumNodes{i}.(Classifiers{c}).(Transformations{t})(trial,:,BestIdx))];
                NS = [NS,mean(S2.NumSplits{i}.(Classifiers{c}).(Transformations{t})(trial,:,BestIdx))];
            end
            TreeDepth = [TreeDepth,mean(TD)];
            nNodes = [nNodes,mean(NN)];
            nSplits = [nSplits,mean(NS)];
            ErrorRate = [ErrorRate,mean(S2.TestError{i}.(Classifiers{c}).(Transformations{t})(:,end))];
            p = [p,S2.dims(i)];
        end
        plot(TreeDepth,ErrorRate,Markers{i},'MarkerEdgeColor',Colors(c,:))
        hold on
    end
end

xlabel('Tree Depth')
ylabel('Error Rate')
title('Trunk')
legend('RF','RerF','RerF2','F-RC','RR-RF','Location','southeast')
ax = gca;
ax.YScale = 'log';
ax.FontSize = FontSize;

% figure;
% 
% gscatter(TreeDepth,ErrorRate,p)
% xlabel('Tree Depth')
% ylabel('Error Rate')
% title('Trunk')
% legend('p = 2','p = 5','p = 10','Location','southeast')
% ax = gca;
% ax.YScale = 'log';
% ax.FontSize = FontSize;
% 
save_fig(gcf,'~/RandomerForest/Figures/Trunk_error_vs_depth')
% 
% figure;
% 
% gscatter(nNodes,ErrorRate,p)
% xlabel('# of nodes')
% ylabel('Error Rate')
% title('Trunk')
% legend('p = 2','p = 5','p = 10','Location','southeast')
% ax = gca;
% ax.YScale = 'log';
% ax.FontSize = FontSize;
% 
% save_fig(gcf,'~/RandomerForest/Figures/Trunk_error_vs_num_nodes')
% 
% figure;
% 
% gscatter(nSplits,ErrorRate,p)
% xlabel('# of splits')
% ylabel('Error Rate')
% title('Trunk')
% legend('p = 2','p = 5','p = 10','Location','southeast')
% ax = gca;
% ax.YScale = 'log';
% ax.FontSize = FontSize;
% 
% save_fig(gcf,'~/RandomerForest/Figures/Trunk_error_vs_num_splits')