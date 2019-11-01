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

acq_params=[];
acq_params.fs=1/obj.grid_vars.dT;
acq_params.f0=obj.input_vars.f0;
acq_params.c=obj.input_vars.c0;
acq_params.t0=obj.xdc.t0/obj.grid_vars.dT;

if obj.input_vars.v == 2
    acq_params.samples=length(obj.grid_vars.t_axis)-1;
else
    acq_params.samples=length(obj.grid_vars.t_axis);
end
acq_params.rx_pos=obj.xdc.out;
acq_params.element_dir=[0 0 1];
acq_params.apex=0;

%acq_params.tx_pos=[0,0,0];
acq_params.theta = 0;
%acq_params.theta=atand(obj.xdc.focus(1)/obj.xdc.focus(2));
acq_params.steer=[sind(acq_params.theta) 0 cosd(acq_params.theta)];
acq_params.focus=[obj.xdc.focus(1) 0 obj.xdc.focus(2)];
ind1=find(obj.xdc.delays==0,1,'first');
foc_pm=sign(obj.xdc.focus(2));
acq_params.t0_var=foc_pm*(sqrt(sum((acq_params.focus-acq_params.rx_pos(ind1,:)).^2))-...
    sqrt(sum((acq_params.focus).^2)))/obj.input_vars.c0/obj.grid_vars.dT;
end