close all
clear
clc

n = 100;    %# samples
dims = round(logspace(log10(2),3,5));
ntrees = 1000;
ntrials = 10;
nclasses = 4;
Classes = 1:nclasses;
ncomponents = 2;    %# of mixture components per class
J = nclasses*ncomponents; %total number of mixture components
p = ones(1,J)/J;    %mixture probabilities

%randomly allocate components evenly across all classes
Class = repmat(transpose(1:nclasses),1,ncomponents);
Class = Class(:);
Class = Class(randperm(length(Class)));

cumrferr = NaN(ntrials,length(dims));
cumf1err = NaN(ntrials,length(dims));
cumf2err = NaN(ntrials,length(dims));
cumf3err = NaN(ntrials,length(dims));
trf = NaN(ntrials,length(dims));
tf1 = NaN(ntrials,length(dims));
tf2 = NaN(ntrials,length(dims));
tf3 = NaN(ntrials,length(dims));

for trial = 1:ntrials
    fprintf('trial %d\n',trial)
    
    for i = 1:length(dims)    
        fprintf('d = %d\n',dims(i))
        
        d = dims(i);
        df = 10*d;   %degrees of freedom for inverse wishart
        nvartosample = ceil(d^(2/3));
        
        Mu = zeros(J,d);
        Sigma = zeros(d,d,J);
        
        for j = 1:J
        Mu(j,:) = mvnrnd(zeros(1,d),eye(d));
        Sigma(:,:,j) = iwishrnd(eye(d),df)*(df-d-1);
        end

        obj = gmdistribution(Mu,Sigma,p);
        [X,idx] = random(obj,n);
        Y = Class(idx);
        Ystr = cellstr(num2str(Y));

        tic
        rf = rpclassificationforest2(ntrees,X,Ystr,'nvartosample',nvartosample,'RandomForest',true);
        trf(trial,i) = toc;
        cumrferr(trial,i) = oobpredict(rf,X,Ystr,'last');
        clear rf
        

        fprintf('Random Forest complete\n')
        
        tic
        f1 = rpclassificationforest2(ntrees,X,Ystr,'s',3,'nvartosample',nvartosample,'mdiff','off','sparsemethod','old');
        tf1(trial,i) = toc;
        cumf1err(trial,i) = oobpredict(f1,X,Ystr,'last');
        clear f1
        
        fprintf('TylerForest complete\n')
        
        tic
        f2 = rpclassificationforest2(ntrees,X,Ystr,'s',3,'nvartosample',nvartosample,'mdiff','off','sparsemethod','new');
        tf2(trial,i) = toc;
        cumf2err(trial,i) = oobpredict(f2,X,Ystr,'last');
        clear f2
        
        fprintf('TylerForest+ complete\n')
        
        tic
        f3 = rpclassificationforest2(ntrees,X,Ystr,'s',3,'nvartosample',nvartosample,'mdiff','on','sparsemethod','new');
        tf3(trial,i) = toc;
        cumf3err(trial,i) = oobpredict(f3,X,Ystr,'last');
        clear f3
        
        fprintf('TylerForest+meandiff complete\n')
    end
end

save('Multimodal_vary_d.mat','cumrferr','cumf1err','cumf2err','cumf3err','trf','tf1','tf2','tf3')
rfsem = std(cumrferr)/sqrt(ntrials);
f1sem = std(cumf1err)/sqrt(ntrials);
f2sem  = std(cumf2err)/sqrt(ntrials);
f3sem  = std(cumf3err)/sqrt(ntrials);
cumrferr = mean(cumrferr);
cumf1err = mean(cumf1err);
cumf2err = mean(cumf2err);
cumf3err = mean(cumf3err);
Ynames = {'cumrferr' 'cumf1err' 'cumf2err' 'cumf3err'};
Enames = {'rfsem' 'f1sem' 'f2sem' 'f3sem'};
lspec = {'-bo','-rx','-gd','-ks'};
facespec = {'b','r','g','k'};
hold on
for i = 1:length(Ynames)
    errorbar(dims,eval(Ynames{i}),eval(Enames{i}),lspec{i},'MarkerEdgeColor','k','MarkerFaceColor',facespec{i});
end
set(gca,'XScale','log')
xlabel('# Ambient Dimensions')
ylabel(sprintf('OOB Error for %d Trees',ntrees))
legend('RandomForest','TylerForest','TylerForest+','TylerForest+meandiff')
fname = sprintf('Multimodal_ooberror_vs_d_n%d_var%d_ntrees%d_ntrials%d',n,1,ntrees,ntrials);
save_fig(gcf,fname)
