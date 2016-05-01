%% Plot misclassification rate, strength, bias, and variance for each benchmark

% Iterate through each benchmark summary file, plot each metric against
% mtry for all classifiers

close all
clear
clc

C = [0 1 1;0 1 0;1 0 1;1 0 0;0 0 0;1 .5 0];
Colors.rf = C(1,:);
Colors.rerf = C(2,:);
Colors.rf_rot = C(3,:);
Colors.rerfr = C(4,:);
Colors.frc = C(5,:);
Colors.rerfdn = C(6,:);

LineWidth.rf = 2;
LineWidth.rerf = 2;
LineWidth.rf_rot = 2;
LineWidth.rerfr = 2;
LineWidth.frc2 = 2;
LineWidth.frc3 = 2.5;
LineWidth.frc4 = 3;
LineWidth.frc5 = 3.5;
LineWidth.frc6 = 4;

FontSize = .16;
axWidth = 1.3;
axHeight = 1.3;
axLeft = [FontSize*5,FontSize*8+axWidth,FontSize*11+axWidth*2,...
    FontSize*14+axWidth*3,FontSize*5,FontSize*8+axWidth,...
    FontSize*11+axWidth*2,FontSize*14+axWidth*3];
axBottom = [FontSize*8+axHeight,FontSize*8+axHeight,FontSize*8+axHeight...
    ,FontSize*8+axHeight,FontSize*4,FontSize*4,FontSize*4,FontSize*4];
legWidth = .25;
legHeight = axHeight;
legLeft = axLeft(end) + axWidth + FontSize;
legBottom = axBottom(end);
figWidth = legLeft(end) + legWidth + FontSize*4;
figHeight = axBottom(1) + axHeight + FontSize*3;


fig = figure;
fig.Units = 'inches';
fig.PaperUnits = 'inches';
fig.Position = [0 0 figWidth figHeight];
fig.PaperPosition = [0 0 figWidth figHeight];
fig.PaperSize = [figWidth figHeight];

load('../Data/Benchmark_data.mat','n','d')

min_d = 1;
max_d = 100;
min_n = 1;
max_n = 50000;

rmidx = [];
for i = 1:length(n)
    if ~(n(i) >= min_n && n(i) < max_n && d(i) >= min_d && d(i) < max_d)
        rmidx = [rmidx i];
    end
end
n(rmidx) = [];
d(rmidx) = [];

InPath = '../Results/Summary/Untransformed/';
contents = dir([InPath,'*.mat']);
OutPath = '../Figures/Untransformed/';

Metrics = {'MR','S','V','B'};
MetricNames = {'Forest Error','Tree Error','Tree Variance',...
    'Tree Bias'};

ClassifierNames = containers.Map({'rf','rerf','rf_rot','rerfr','frc'},...
    {'RF','RerF','RotRF','RerF(rank)','F-RC'});


for i = 1:length(contents)
    BenchmarkName = strsplit(contents(i).name,'_untransformed_summary.mat');
    BenchmarkName = BenchmarkName{1};
    InFile = [InPath,contents(i).name];
    load(InFile)
    for m = 1:length(Metrics)
        Metric = Metrics{m};
        Classifiers = fieldnames(Summary.(Metric));
        ax = subplot(1,length(Metrics),m);
        hold on
        LineNames = [];
        for c = 1:length(Classifiers)
            cl = Classifiers{c};
            if length(Summary.NMIX.(cl)) <= 0
                plot(Summary.MTRY.(cl),Summary.(Metric).(cl),...
                    'Color',Colors.(cl),'LineWidth',LineWidth.(cl))
                LineNames = [LineNames,ClassifierNames(cl)];
            else
                for k = 1:length(Summary.NMIX.(cl))
                    clname = [ClassifierNames(cl),...
                        num2str(Summary.NMIX.(cl)(k))];
                    plot(Summary.MTRY.(cl),Summary.(Metric).(cl)(:,k),...
                        'Color',Colors.(cl),...
                        'LineWidth',LineWidth.([cl,num2str(Summary.NMIX.(cl)(k))]))
                    LineNames = [LineNames,clname];
                end
            end
        end
        if m == 1
            title(sprintf('%s (n = %d, p = %d)',BenchmarkName,n(i),d(i)))
        end
        xlabel('mtry')
        ylabel(MetricNames(m))
        legend(LineNames)
        ax.LineWidth = 2;
        ax.FontUnits = 'inches';
        ax.FontSize = FontSize;
        ax.Units = 'inches';
        ax.Position = [axLeft(m),axBottom(m),axWidth,axHeight];
        ax.Box = 'off';
        if m == length(Metrics)
            l = legend(LineNames);
            l.Units = 'inches';
            l.Position = [legLeft,legBottom,legWidth,legHeight];
            leg.Box = 'off';
        end
    end
    save_fig(gcf,[OutPath,BenchmarkName,'_summary'])
    close
end