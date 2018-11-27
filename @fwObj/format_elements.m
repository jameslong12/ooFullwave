function obj = format_elements(obj)

%%% Set inmap to transmit elements
obj.xdc.e_center = round(mean(obj.xdc.e_ind,2));
for i = 1:size(obj.xdc.e_ind,1)
obj.xdc.inmap(obj.xdc.e_ind(i,1):obj.xdc.e_ind(i,end),1:3) = 1;
end

%%% fix transmit



end