function obj = focus_linear(obj, focus)

%%% Initialize inmap and incoords %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.xdc.inmap(:,1:3) = 1;
obj.xdc.incoords = mapToCoords(obj.xdc.inmap);

%%% Calculate delays and generate icmat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dur = 2;
fy = (focus(1)-obj.grid_vars.y_axis(1))/obj.grid_vars.dY+1;
fz = (focus(2)-obj.grid_vars.z_axis(1))/obj.grid_vars.dZ+1;
t = (0:obj.grid_vars.nT-1)/obj.grid_vars.nT*obj.input_vars.td-obj.input_vars.ncycles/obj.input_vars.omega0*2*pi;

%%% Call focus_transmit to focus transmit beam %%%%%%%%%%%%%%%%%%%%%%%%%%%%
coord_row = 1:size(obj.xdc.incoords,1)/3;
icvec = exp(-(1.05*t*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur)).*sin(t*obj.input_vars.omega0)*obj.input_vars.p0;
icmat = average_icmat(obj,focus_transmit(obj,fy,fz,icvec,obj.xdc.incoords(coord_row,:)));
t=t-obj.grid_vars.dT/obj.input_vars.cfl;

coord_row = size(obj.xdc.incoords,1)/3+1:2*size(obj.xdc.incoords,1)/3;
icvec = exp(-(1.05*t*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur)).*sin(t*obj.input_vars.omega0)*obj.input_vars.p0;
icmat_add = average_icmat(obj,focus_transmit(obj,fy,fz,icvec,obj.xdc.incoords(coord_row,:)));
icmat = [icmat; icmat_add];
t=t-obj.grid_vars.dT/obj.input_vars.cfl;

coord_row = 2*size(obj.xdc.incoords,1)/3+1:size(obj.xdc.incoords,1);
icvec = exp(-(1.05*t*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur)).*sin(t*obj.input_vars.omega0)*obj.input_vars.p0;
icmat_add = average_icmat(obj,focus_transmit(obj,fy,fz,icvec,obj.xdc.incoords(coord_row,:)));
obj.xdc.icmat = [icmat; icmat_add];

obj.xdc.out = zeros(obj.xdc.n,3);
for i=1:obj.xdc.n
    obj.xdc.out(i,1) = mean(obj.grid_vars.y_axis(obj.xdc.e_ind(i,1):obj.xdc.e_ind(i,2)));    
end
delays=get_delays(obj,focus);
obj.xdc.t0 = -(obj.input_vars.ncycles/obj.input_vars.omega0*2*pi+max(delays));

end