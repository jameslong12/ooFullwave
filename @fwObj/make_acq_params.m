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
acq_params.tx_pos = [0,0,0];
acq_params.tx_apod = zeros(obj.xdc.n,1);
acq_params.tx_apod(obj.xdc.on_elements) = 1;
acq_params.focus = [obj.xdc.focus(1) 0 obj.xdc.focus(2)];
if strcmp(obj.xdc.type,'curvilinear')
    acq_params.apex = obj.xdc.r;
    acq_params.theta = atand(obj.xdc.focus(1)/(obj.xdc.focus(2)+obj.xdc.r));
else
    acq_params.apex=0;
    acq_params.theta = 0;
end
acq_params.steer = [sind(acq_params.theta) 0 cosd(acq_params.theta)];
[~,n] = max(obj.xdc.icmat(1:obj.grid_vars.nY,:)~=0,[],1);
acq_params.t0_var = min(n(n~=1));

end