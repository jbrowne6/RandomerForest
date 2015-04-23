close all
clear
clc

fpath = mfilename('fullpath');
findex = strfind(fpath,'/');
rootDir=fpath(1:findex(end-1));
p = genpath(rootDir);
gits=strfind(p,'.git');
colons=strfind(p,':');
for i=0:length(gits)-1
endGit=find(colons>gits(end-i),1);
p(colons(endGit-1):colons(endGit)-1)=[];
end
addpath(p);

n = 100;
dims = round(logspace(log10(2),3,10));
ntrials = 10;
ntrees = 1500;
cumrferr = NaN(ntrials,length(dims));
cumf1err = NaN(ntrials,length(dims));
cumf2err = NaN(ntrials,length(dims));
cumf3err = NaN(ntrials,length(dims));
trf = NaN(ntrials,length(dims));
tf1 = NaN(ntrials,length(dims));
tf2 = NaN(ntrials,length(dims));
tf3 = NaN(ntrials,length(dims));
Class = [0;1];

parpool;
for trial = 1:ntrials
    fprintf('trial %d\n',trial)
    for i = 1:length(dims)
        d = dims(i);
        fprintf('dimensions = %d\n',dims(i))
        d_idx = 1:d;
        nvartosample = ceil(d^(2/3));
        mu1 = 1./sqrt(d_idx);
        mu0 = -1*mu1;
        Mu = cat(1,mu0,mu1);
        Sigma = ones(1,d);
        obj = gmdistribution(Mu,Sigma);
        [X,idx] = random(obj,n);
        Y = cellstr(num2str(Class(idx)));
        
        tic
        rf = rpclassificationforest(ntrees,X,Y,'nvartosample',nvartosample,'RandomForest',true);
        trf(trial,i) = toc;
        rferr = oobpredict(rf,X,Y,'every');
        cumrferr(trial,i) = rferr(end);
        
        fprintf('Random Forest complete\n')
        
        tic
        f1 = rpclassificationforest(ntrees,X,Y,'s',3,'nvartosample',nvartosample,'mdiff','off','sparsemethod','old');
        tf1(trial,i) = toc;
        f1err = oobpredict(f1,X,Y,'every');
        cumf1err(trial,i) = f1err(end);
        
        fprintf('TylerForest complete\n')
        
        tic
        f2 = rpclassificationforest(ntrees,X,Y,'s',3,'nvartosample',nvartosample,'mdiff','off','sparsemethod','new');
        tf2(trial,i) = toc;
        f2err = oobpredict(f2,X,Y,'every');
        cumf2err(trial,i) = f2err(end);
        
        fprintf('TylerForest+ complete\n')
        
        tic
        f3 = rpclassificationforest(ntrees,X,Y,'s',3,'nvartosample',nvartosample,'mdiff','on','sparsemethod','new');
        tf3(trial,i) = toc;
        f3err = oobpredict(f3,X,Y,'every');
        cumf3err(trial,i) = f3err(end);
        
        fprintf('TylerForest+meandiff complete\n')
    end
end

save('Trunk_vary_d.mat','cumrferr','cumf1err','cumf2err','cumf3err','trf','tf1','tf2','tf3')
rfsem = std(cumrferr)/sqrt(ntrials);
f1sem = std(cumf1err)/sqrt(ntrials);
f2sem  = std(cumf2err)/sqrt(ntrials);
f3sem = std(cumf3err)/sqrt(ntrials);
cumrferr = mean(cumrferr);
cumf1err = mean(cumf1err);
cumf2err = mean(cumf2err);
cumf3err = mean(cumf3err);
Ynames = {'cumrferr' 'cumf1err' 'cumf2err' 'cumf3err'};
Enames = {'rfsem' 'f1sem' 'f2sem' 'f3sem'};
lspec = {'-bo','-rx','-gd','-ks'};
hold on
for i = 1:length(Ynames)
    errorbar(dims,eval(Ynames{i}),eval(Enames{i}),lspec{i});
end
set(gca,'XScale','log')
xlabel('# ambient dimensions')
ylabel('oob error')
title('Trunk')
legend('RandomForest','TylerForest','TylerForest+','TylerForest+meandiff')
fname = sprintf('Trunk_ooberror_vs_d_n%d_var%d_ntrees%d_ntrials%d_v2',n,Sigma(1),ntrees,ntrials);
save_fig(gcf,fname)

figure(2)
rfsem = std(trf)/sqrt(ntrials);
f1sem = std(tf1)/sqrt(ntrials);
f2sem  = std(tf2)/sqrt(ntrials);
f3sem = std(tf3)/sqrt(ntrials);
trf = mean(trf);
tf1 = mean(tf1);
tf2 = mean(tf2);
tf3 = mean(tf3);
Ynames = {'trf' 'tf1' 'tf2' 'tf3'};
Enames = {'rfsem' 'f1sem' 'f2sem' 'f3sem'};
lspec = {'-bo','-rx','-gd','-ks'};
hold on
for i = 1:length(Ynames)
    errorbar(dims,eval(Ynames{i}),eval(Enames{i}),lspec{i});
end
set(gca,'XScale','log')
xlabel('# ambient dimensions')
ylabel('Training time (sec)')
title('Trunk')
legend('RandomForest','TylerForest','TylerForest+','TylerForest+meandiff')
fname = sprintf('Trunk_time_vs_d_n%d_var%d_ntrees%d_ntrials%d_v2',n,Sigma(1),ntrees,ntrials);
save_fig(gcf,fname)