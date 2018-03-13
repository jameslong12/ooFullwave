function tfield = calc_tfield(obj, tx_params)

%  Function to calculate tfield within make_xdc method of fwObj
%
%  Parameters:
%           obj             - Fullwave simulation object
%           tx_params       - Structure of transmit parameters
%
%  Return:
%           tfield          - Time field of delays
%
%  James Long, 03/09/2018

if strcmp(obj.xdc.type, 'curvilinear')
    %%% Calculate delays due to curvilinear shape and steering %%%%%%%%%%%%
    curv_delays = obj.grid_vars.z_axis(obj.xdc.idx_z)/obj.input_vars.c0;
    curv_delays = curv_delays-min(curv_delays);
    
    if strcmp(tx_params.event, 'plane')
        theta_delays = obj.grid_vars.y_axis(obj.xdc.idx_y)*tand(tx_params.theta)/obj.input_vars.c0;
        theta_delays = theta_delays-min(theta_delays);
        delays = curv_delays+theta_delays;
    elseif strcmp(tx_params.event, 'focused')
        y_pos =  [obj.grid_vars.y_axis(obj.xdc.idx_y)' zeros(length(obj.xdc.idx_y),1)];
        foc_delays = -sqrt(sum((y_pos-tx_params.focus).^2,2))/obj.input_vars.c0;
        foc_delays = foc_delays-min(foc_delays);
        delays = curv_delays+foc_delays';
    end
    
elseif strcmp(obj.xdc.type, 'linear')
    if strcmp(tx_params.event, 'plane')
        theta_delays = obj.grid_vars.y_axis(obj.xdc.idx_y)*tand(tx_params.theta)/obj.input_vars.c0;
        delays = (theta_delays-min(theta_delays))';
    elseif strcmp(tx_params.event, 'focused')
        y_pos =  [obj.grid_vars.y_axis(obj.xdc.idx_y)' zeros(length(obj.xdc.idx_y),1)];
        foc_delays = -sqrt(sum((y_pos-tx_params.focus).^2,2))/obj.input_vars.c0;
        delays = (foc_delays-min(foc_delays))';
    end
    
else
    error('Unrecognized type.')
end

tfield = repmat(obj.grid_vars.t_axis,size(obj.xdc.incoords,1)/4,1)-repmat(delays',1,obj.grid_vars.nT);

end