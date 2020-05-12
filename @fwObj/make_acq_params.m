function acq_params = make_acq_params(obj)

%  Function to calculate acquisition parameters to match beamforming used
%  by nbb5 and wjl11.
%
%  Calling:
%           acq_params = obj.make_acq_params()
%
%  Returns:
%           acq_params                  - Acquisition parameters for
%                                         beamforming
%
%  Nick Bottenus, 11/27/2018

acq_params = [];
acq_params.fs = 1/obj.grid_vars.dT;
acq_params.f0 = obj.input_vars.f0;
acq_params.c = obj.input_vars.c0;
acq_params.t0 = -length(obj.xdc.pulse)/2;
if obj.input_vars.v == 2
    acq_params.samples=length(obj.grid_vars.t_axis)-1;
else
    acq_params.samples=length(obj.grid_vars.t_axis);
end
acq_params.rx_pos = obj.xdc.out;
acq_params.tx_apod = false(obj.xdc.n,1);
acq_params.tx_apod(obj.xdc.on_elements) = true;
acq_params.focus = [obj.xdc.focus(1) 0 obj.xdc.focus(2)];
if strcmp(obj.xdc.type,'curvilinear')
    acq_params.apex = obj.xdc.r;
    acq_params.theta = atand(obj.xdc.focus(1)/(obj.xdc.focus(2)+obj.xdc.r));
    acq_params.tx_pos = [obj.xdc.r*sind(acq_params.theta) 0 ...
        obj.xdc.r*cosd(acq_params.theta)-obj.xdc.r];
    
else
    acq_params.apex=0;
    acq_params.theta = atand(obj.xdc.focus(1)/obj.xdc.focus(2));
    rx_pos = acq_params.rx_pos(obj.xdc.on_elements,:);
    acq_params.tx_pos = mean(rx_pos);
    acq_params.theta = 0;
end
acq_params.steer = [sind(acq_params.theta) 0 cosd(acq_params.theta)];

ind1=find(obj.xdc.delays==0,1,'first');
[~,ind2] = max(obj.xdc.delays);
foc_pm=sign(obj.xdc.focus(2));
rx_pos = acq_params.rx_pos(obj.xdc.on_elements,:);
acq_params.t0_var=foc_pm*(sqrt(sum((acq_params.focus-rx_pos(ind1,:)).^2))-...
    sqrt(sum((acq_params.focus-rx_pos(ind2,:)).^2)))/obj.input_vars.c0/obj.grid_vars.dT;

end