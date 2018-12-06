function icmat_corr = average_icmat(obj,icmat)

icmat_avg = zeros(size(icmat));
ind_avg = round(mean(obj.xdc.e_ind,2));

for i = 1:size(obj.xdc.e_ind,1)
    inds = obj.xdc.e_ind(i,1):obj.xdc.e_ind(i,end);
    icmat_avg(inds,:) = repmat(icmat(ind_avg(i),:),[length(inds) 1]);
end

icmat_corr = zeros(size(icmat_avg));
mask = icmat_avg~=0;
[~,mi] = max(mask,[],2); mii = min(mi(mi~=1));

icmat_corr(:,1:size(icmat_corr,2)-mii+1) = icmat_avg(:,mii:end);

end