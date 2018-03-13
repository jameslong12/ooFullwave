function obj = make_xdc(obj, tx_params)

%  Function to create transducer related fields
%
%  Calling:
%           tx_params = struct('name','c52v','event','plane','theta',0)
%           obj.make_xdc(tx_params)
%
%  Parameters:
%           tx_params       - Structure of transmit parameters
%                               name:   Transducer name
%                               event:  Transmit event ('plane'
%                                       or 'focused')
%                               focus:  Focal position in [y,z]
%                               theta:  Transmit steering angle
%
%  James Long 03/10/2018

obj.xdc = xdc_lib(tx_params.name);
obj.xdc.inmap = zeros(size(obj.field_maps.cmap));
obj.xdc.outmap = zeros(size(obj.field_maps.cmap));

%%% Check if grid spacing if adequate for modeling %%%%%%%%%%%%%%%%%%%%%%%%
if obj.grid_vars.dY > obj.xdc.pitch, error('Grid spacing is too large.'); end

if strcmp(obj.xdc.type, 'curvilinear')
    dtheta = atand(obj.xdc.pitch/obj.xdc.r);
    span = 2*obj.xdc.r*sind((obj.xdc.n-1)*dtheta/2);
    y = -span/2:obj.grid_vars.dY:span/2;
    z = sqrt(obj.xdc.r^2.-y.^2); z = z-min(z);
    
    %%% Calculate indices of xdc in space %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [~,idx_y] = min(abs(obj.grid_vars.y_axis-y'));
    idx_y = find(idx_y ~= 1 & idx_y ~= length(y));
    [~,idx_z] = min(abs(obj.grid_vars.z_axis'-z));
    idx_z = idx_z(2:end-1);
    for i = 1:length(idx_y)
        obj.xdc.inmap(idx_y(i),idx_z(i):idx_z(i)+3) = ones(4,1);
        obj.xdc.outmap(idx_y(i),idx_z(i)+3) = 1;
    end
    obj.xdc.idx_y = idx_y; obj.xdc.idx_z = idx_z;
    obj.xdc.incoords = mapToCoords(obj.xdc.inmap);
    obj.xdc.outcoords = mapToCoords(obj.xdc.outmap);
    
    %%% Calculate delays and generate icmat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tfield = calc_tfield(obj, tx_params);
    dur = 2; % exponential drop-off of envelope;
    icvec1 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin(tfield*obj.input_vars.omega0)*obj.input_vars.p0;
    icvec2 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin((tfield-obj.grid_vars.dY/obj.input_vars.c0)*obj.input_vars.omega0)*obj.input_vars.p0;
    icvec3 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin((tfield-2*obj.grid_vars.dY/obj.input_vars.c0)*obj.input_vars.omega0)*obj.input_vars.p0;
    icvec4 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin((tfield-3*obj.grid_vars.dY/obj.input_vars.c0)*obj.input_vars.omega0)*obj.input_vars.p0;
    obj.xdc.icmat = [icvec1; icvec2; icvec3; icvec4];
    
    %%% Calculate element index spans %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    e_size = round(size(idx_y,2)/obj.xdc.n);
    e_start = round(linspace(1, size(idx_y,2)-e_size+1, obj.xdc.n));
    obj.xdc.e_ind = [e_start' (e_start+e_size)'];
    
elseif strcmp(obj.xdc.type, 'linear')
    dtheta = atand(obj.xdc.pitch/obj.xdc.r);
    span = 2*obj.xdc.r*sind((obj.xdc.n-1)*dtheta/2);
    y = -span/2:obj.grid_vars.dY:span/2;
    z = sqrt(obj.xdc.r^2.-y.^2); z = z-min(z);
    
    %%% Calculate indices of xdc in space %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [~,idx_y] = min(abs(obj.grid_vars.y_axis-y'));
    idx_y = find(idx_y ~= 1 & idx_y ~= length(y));
    [~,idx_z] = min(abs(obj.grid_vars.z_axis'-z));
    idx_z = idx_z(2:end-1);
    for i = 1:length(idx_y)
        obj.xdc.inmap(idx_y(i),idx_z(i):idx_z(i)+3) = ones(4,1);
        obj.xdc.outmap(idx_y(i),idx_z(i)+3) = 1;
    end
    obj.xdc.idx_y = idx_y; obj.xdc.idx_z = idx_z;
    obj.xdc.incoords = mapToCoords(obj.xdc.inmap);
    obj.xdc.outcoords = mapToCoords(obj.xdc.outmap);
    
    %%% Calculate delays and generate icmat %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tfield = calc_tfield(obj, tx_params);
    dur = 2; % exponential drop-off of envelope;
    icvec1 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin(tfield*obj.input_vars.omega0)*obj.input_vars.p0;
    icvec2 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin((tfield-obj.grid_vars.dY/obj.input_vars.c0)*obj.input_vars.omega0)*obj.input_vars.p0;
    icvec3 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin((tfield-2*obj.grid_vars.dY/obj.input_vars.c0)*obj.input_vars.omega0)*obj.input_vars.p0;
    icvec4 = exp(-(1.05*tfield*obj.input_vars.omega0/(obj.input_vars.ncycles*pi)).^(2*dur))...
        .*sin((tfield-3*obj.grid_vars.dY/obj.input_vars.c0)*obj.input_vars.omega0)*obj.input_vars.p0;
    obj.xdc.icmat = [icvec1; icvec2; icvec3; icvec4];
    
    %%% Calculate element index spans %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    e_size = round(size(idx_y,2)/obj.xdc.n);
    e_start = round(linspace(1, size(idx_y,2)-e_size+1, obj.xdc.n));
    obj.xdc.e_ind = [e_start' (e_start+e_size)'];
    
else
    error('Unsupported transducer type.')
end

end