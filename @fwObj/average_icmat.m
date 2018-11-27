function icmat_avg = average_icmat(obj,icmat)

icmat_avg = zeros(size(icmat));

%%% Reindex elements based on icmat, not inmap
ist = obj.xdc.e_ind(1);
for i = 1:size(obj.xdc.e_ind,1)
    ind_new(i,:) = [ist ist+obj.xdc.e_ind(i,end)-obj.xdc.e_ind(i,1)];
    ist = ist+obj.xdc.e_ind(i,end)-obj.xdc.e_ind(i,1)+1;
end
ind_avg = round(mean(ind_new,2));
%inds = (obj.xdc.e_ind(:,1):obj.xdc.e_ind(:,end))-min(obj.xdc.e_ind(:))+1;

for i = 1:size(ind_new,1)
    inds = ind_new(i,1):ind_new(i,end);
    icmat_avg(inds,:) = repmat(icmat(ind_avg(i),:),[length(inds) 1]);
end

end