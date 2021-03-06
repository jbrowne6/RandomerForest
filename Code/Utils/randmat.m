function M = srpmat(d,k,method,varargin)
    if strcmp(method,'dense')
        s = varargin{1};
        M = vec2mat(randsample([0 1],d*k,true,[1-1/s 1/s]),k);
        M(M==1) = rand(sum(M(:)==1),1)*2 - 1;
    elseif strcmp(method,'sparse-unadjusted')
        s = varargin{1};
        M = sparse(d,k);
        nnzs = round(k*d*s);
        nzs=randperm(d*k,nnzs);
        npos = rand(nnzs,1) > 0.5;
        M(nzs(npos))=1;
        M(nzs(~npos))=-1;
    elseif strcmp(method,'sparse-binary')
        s = varargin{1};
        kk = varargin{3};
        M = zeros(d,kk);
        nnzs = round(kk*d*s);
        nzs=randperm(d*kk,nnzs);
        npos = rand(nnzs,1) > 0.5;
        M(nzs(npos))=1;
        M(nzs(~npos))=-1;
        M = unique(M(:,any(M))','rows','stable')';
        M = M(:,1:min(k,size(M,2)));
        M = sparse(M);
    elseif strcmp(method,'sparse-continuous')
        s = varargin{1};
        kk = varargin{3};
        M = zeros(d,kk);
        nnzs = round(kk*d*s);
        nzs=randperm(d*kk,nnzs);
        M(nzs) = rand(1,nnzs)*2 - 1;
        M = M(:,any(M));
        M = M(:,1:min(k,size(M,2)));
        M = sparse(M);
    elseif strcmp(method,'frc')
        nmix = varargin{2};
        M = zeros(d,k);
%         p = 1;
%         for i = 1:nmix-1
%             p = p*(d-i)/d;
%         end
%         kk = round(4*k/p);
%         go = true;
%         while go
%             idx = randi(d,nmix,kk);
%             idx = idx(:,all(diff(sort(idx)),1));
%             go = size(idx,2) < k;
%         end
%         idx = idx(:,1:k);
        idx = randperms(d,nmix,k);
        idx = (ndgrid(1:k,1:nmix)'-1)*d + idx;
        M(idx) = rand(1,nmix*k)*2 - 1;
        M = sparse(M);
    elseif strcmp(method,'uniform-nnzs')
        nmix = varargin{2};
        min_nmix = min(nmix);
        max_nmix = max(nmix);
        M = zeros(d,k);
%         p = 1;
%         for i = 1:max_nmix-1
%             p = p*(d-i)/d;
%         end
%         kk = round(4*k/p);
%         go = true;
%         while go
%             idx = randi(d,max_nmix,kk);
%             idx = idx(:,all(diff(sort(idx)),1));
%             go = size(idx,2) < k;
%         end
%         idx = idx(:,1:k);
        idx = randperms(d,max_nmix,k);
        idx = (ndgrid(1:k,1:max_nmix)'-1)*d + idx;
%         nnzs = round(rand(1,k)*(max_nmix-min_nmix)+min_nmix);
        nnzs = nmix(randi(length(nmix),1,k));
        for i = 1:length(nmix)
            idx(nmix(i)+1:end,nnzs==nmix(i)) = NaN;
        end
        idx(isnan(idx(:))) = [];
        M(idx(:)) = rand(1,length(idx(:)))*2 - 1;
        M = sparse(M);
    end
end