function obj = plane_linear(obj, theta)

%%% Initialize inmap and incoords %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.xdc.inmap(1:obj.grid_vars.nY,1:3) = 1;
obj.xdc.incoords = mapToCoords(obj.xdc.inmap);

%%% Calculate delays and generate icmat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dur = 2;
t = (0:obj.grid_vars.nT-1)/obj.grid_vars.nT*obj.input_vars.td-obj.input_vars.ncycles/obj.input_vars.omega0*2*pi;

%%% Call focus_transmit to focus transmit beam %%%%%%%%%%%%%%%%%%%%%%%%%%%%
coord_row = 1:size(obj.xdc.incoords,1)/3;
icvec = exp(-(1.05*t*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur)).*sin(t*obj.input_vars.omega0)*obj.input_vars.p0;
icmat = plane_transmit(obj,theta,icvec,obj.xdc.incoords(coord_row,:));
t=t-obj.grid_vars.dT/obj.input_vars.cfl;

coord_row = size(obj.xdc.incoords,1)/3+1:2*size(obj.xdc.incoords,1)/3;
icvec = exp(-(1.05*t*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur)).*sin(t*obj.input_vars.omega0)*obj.input_vars.p0;
icmat_add = plane_transmit(obj,theta,icvec,obj.xdc.incoords(coord_row,:)); icmat = [icmat; icmat_add];
t=t-obj.grid_vars.dT/obj.input_vars.cfl;

coord_row = 2*size(obj.xdc.incoords,1)/3+1:size(obj.xdc.incoords,1);
icvec = exp(-(1.05*t*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur)).*sin(t*obj.input_vars.omega0)*obj.input_vars.p0;
icmat_add = plane_transmit(obj,theta,icvec,obj.xdc.incoords(coord_row,:)); obj.xdc.icmat = [icmat; icmat_add];
