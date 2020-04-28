function obj = focus_xdc(obj, focus, fc, fbw, excitation, bwr, tpe)

%  Function to create transmit related fields. Must call obj.make_xdc()
%  prior to use.
%
%  Calling:
%           obj.focus_xdc(focus)
%
%  Parameters:
%           focus               - Focal point in [y z] (m)
%           fc                  - Center frequency of transducer (Hz) [obj.input_vars.f0]
%           fbw                 - Fractional bandwidth of transducer [0.8]
%           excitation          - Vector of excitation in time
%           bwr                 - Fractional bandwidth reference level [-6 dB]
%           tpe                 - Cutoff for trailing pulse envelope [-40 dB]
%
%  Returns:
%           obj.xdc.inmap       - Input map for initial conditions
%           obj.xdc.incoords    - Paired coordinates of inmap
%           obj.xdc.outmap      - Output map for data collection
%           obj.xdc.outcoords   - Paired coordinates of outmap
%           obj.xdc.icmat       - Initial condition matrix for transmit
%           obj.xdc.delays      - Time delays on elements in transmit
%           obj.xdc.t0          - Time of first time index (s) for beamforming
%
%  James Long 04/16/2020

if ~exist('fc','var')||isempty(fc), fc = obj.input_vars.f0; end
if ~exist('fbw','var')||isempty(fbw), fbw = 0.8; end
if ~exist('bwr','var')||isempty(bwr), bwr=-6; end
if ~exist('tpe','var')||isempty(tpe), tpe=-40; end

%%% Define in/out parameters, shift z_axis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(obj.xdc.type, 'curvilinear') 
    layers = 5;
    sector = obj.xdc.pitch*obj.xdc.n; theta_xdc = sector/obj.xdc.r;
    theta = linspace(-theta_xdc/2,theta_xdc/2,obj.xdc.n);
    zp = cos(theta)*obj.xdc.r; zp = zp-min(zp);
    inmap0 = zeros(size(obj.field_maps.cmap)); inmap0(:,1) = 1;
    [zg,yg] = meshgrid(obj.grid_vars.z_axis,obj.grid_vars.y_axis);
    inmap0(yg.^2+(zg+obj.xdc.r-max(zp)).^2<obj.xdc.r^2) = 1;
    inmap = zeros(size(inmap0));
    for i=1:size(inmap0,1)
        j=find(inmap0(i,:)==0); j=j(1);
        inmap0(i,1:max([j-2 0]))=0;
        inmap(i,find(inmap0(i,:)==1)+layers-1) = 1;
    end
    obj.xdc.outmap = inmap;
    
    incoords = make_incoords_row(obj,inmap);
    obj.xdc.outcoords = incoords;
    for i = 1:layers-1
        inter = circshift(inmap,[0 -i]);
        incoords = [incoords; make_incoords_row(obj,inter)];
    end
    for i = 1:size(inmap,1)
        inmap(i,find(inmap0(i,:)==1):find(inmap0(i,:)==1)+layers-1) = 1;
    end
    obj.xdc.inmap = inmap; obj.xdc.incoords = incoords;
    obj.grid_vars.z_axis = obj.grid_vars.z_axis-max(zp)-(layers-1)*obj.grid_vars.dZ;
    
elseif strcmp(obj.xdc.type, 'linear')    
    layers = 3;
    inmap = zeros(size(obj.field_maps.cmap));
    inmap(:,layers) = 1;
    obj.xdc.outmap = inmap;
    incoords = make_incoords_row(obj,inmap);
    obj.xdc.outcoords = incoords;
    for i = 1:layers-1
        inter = circshift(inmap,[0 -i]);
        incoords = [incoords; make_incoords_row(obj,inter)];
    end
    inmap(:,1:layers) = 1;
    obj.xdc.inmap = inmap; obj.xdc.incoords = incoords;
    obj.grid_vars.z_axis = obj.grid_vars.z_axis-(layers-1)*obj.grid_vars.dZ;
    
else
    error('Unsupported transducer type.')
end

%%% Calculate impulse response and transmitted pulse %%%%%%%%%%%%%%%%%%%%%%
fy = (focus(1)-obj.grid_vars.y_axis(1))/obj.grid_vars.dY+1;
fz = (focus(2)-obj.grid_vars.z_axis(1))/obj.grid_vars.dZ+1;
tc = gauspuls('cutoff',fc,fbw,bwr,tpe);
fs=1/obj.grid_vars.dT;
tv = -tc:1/fs:tc;
impulse_response = gauspuls(tv,fc,fbw);
impulse_response = impulse_response-mean(impulse_response);
obj.xdc.impulse_t = tv;
obj.xdc.impulse = impulse_response;
if ~exist('excitation','var')||isempty(excitation)
    excitation = sin(2*pi*obj.input_vars.f0*(0:1/fs:obj.input_vars.ncycles/obj.input_vars.f0));
end
pulse = conv(impulse_response,excitation);
pulse = pulse/max(abs(pulse));
obj.xdc.pulse_t = (0:length(pulse)-1)/fs;
obj.xdc.pulse = pulse;
obj.xdc.excitation_t = (0:length(excitation)-1)/fs;
obj.xdc.excitation = excitation;

%%% Calculate delays for all layers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ey = (obj.xdc.out(:,1)-obj.grid_vars.y_axis(1))/obj.grid_vars.dY;
ez = (obj.xdc.out(:,3)-obj.grid_vars.z_axis(1))/obj.grid_vars.dZ;
t = (0:obj.grid_vars.nT-1)/obj.grid_vars.nT*obj.input_vars.td-obj.input_vars.ncycles/obj.input_vars.omega0*2*pi;
icvec = zeros(size(obj.grid_vars.t_axis));
icvec(1:length(pulse)) = pulse*obj.input_vars.p0;
icmat_sub = focus_transmit(obj,fy,fz,icvec,[ey(:) ez(:)]);
icmat = zeros(obj.grid_vars.nY,obj.grid_vars.nT);

ct = 0;
for i = obj.xdc.on_elements
    ct = ct+1;
    indy = obj.xdc.e_ind(i,1):obj.xdc.e_ind(i,2);
    icmat(indy,:) = repmat(icmat_sub(i,:),numel(indy),1)*obj.xdc.tx_apod(ct);
end
for i = 1:layers-1
    tnew=t-i*(obj.grid_vars.dT/obj.input_vars.cfl);
    icvec = interp1(t,icvec,tnew,[],0);
    icmat_sub = focus_transmit(obj,fy,fz,icvec,[ey(:) ez(:)]);
    icmat_add = zeros(obj.grid_vars.nY,obj.grid_vars.nT);
    ct = 0;
    for i = obj.xdc.on_elements
        ct = ct+1;
        ind = obj.xdc.e_ind(i,1):obj.xdc.e_ind(i,2);
        icmat_add(ind,:) = repmat(icmat_sub(i,:),numel(ind),1)*obj.xdc.tx_apod(ct);
    end
    icmat = [icmat; icmat_add];
end

obj.xdc.icmat = icmat;
obj.xdc.delays = get_delays(obj,focus);
obj.xdc.t0 = -(obj.input_vars.ncycles/obj.input_vars.omega0*2*pi);

end