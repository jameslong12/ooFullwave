function icmat_avg = average_icmat(obj,icmat)

icmat_avg = zeros(size(icmat));
ind_avg = round(mean(obj.xdc.e_ind,2));

for i = 1:size(obj.xdc.e_ind,1)
    inds = obj.xdc.e_ind(i,1):obj.xdc.e_ind(i,end);
    icmat_avg(inds,:) = repmat(icmat(ind_avg(i),:),[length(inds) 1]);
end

end