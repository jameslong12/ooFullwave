function obj = make_xdc(obj)

%  Function to create transducer related fields
%
%  Calling:
%           obj.make_xdc()
%
%  Parameters:
%           obj.xdc.type        - Type of transducer (only 'linear'
%                                 currently supported)
%           obj.xdc.pitch       - Center-to-center element spacing (m)
%           obj.xdc.kerf        - Interelement spacing (m)
%           obj.xdc.n           - Number of elements
%           obj.xdc.on_elements - (Optional) Elements selected for transmit
%                                 (default = 1:obj.xdc.n)
%           obj.xdc.tx_apod     - (Optional) Vector of transmit apodization
%                                 applied to elements (default =
%                                 ones(length(obj.xdc.on_elements),1))
%           obj.xdc.p_size      - (Optional) Downsampling factors for
%                                 [t,y,z] (pressure field only)
%                                 (default = [1,1,1])
%
%  Returns:
%           obj.xdc.width       - Element width (m)
%           obj.xdc.e_ind       - Lateral element indices on grid
%
%  James Long 12/06/2018

obj.xdc.inmap = zeros(size(obj.field_maps.cmap));
obj.xdc.outmap = zeros(size(obj.field_maps.cmap));

% Check grid spacing
if obj.grid_vars.dY > obj.xdc.pitch, error('Grid spacing is too large.'); end

if strcmp(obj.xdc.type, 'curvilinear')
    assert(isfield(obj.xdc,'pitch'),'Unidentified element pitch in obj.xdc.')
    assert(isfield(obj.xdc,'kerf'),'Unidentified element kerf in obj.xdc.')
    assert(isfield(obj.xdc,'n'),'Unidentified number of elements (n) in obj.xdc.')
    assert(isfield(obj.xdc,'r'),'Unidentified convex radius (r) in obj.xdc.')
    
    if ~isfield(obj.xdc,'on_elements'); obj.xdc.on_elements = 1:obj.xdc.n; end
    if ~isfield(obj.xdc,'tx_apod'); obj.xdc.tx_apod = ones(length(obj.xdc.on_elements),1); end
    if ~isfield(obj.xdc,'p_size'); obj.xdc.p_size = [1,1,1]; end
    assert(length(obj.xdc.tx_apod)==length(obj.xdc.on_elements),'Transmit apodization must match on elements.');
    
    obj.xdc.width = obj.xdc.pitch-obj.xdc.kerf;
    sector = obj.xdc.pitch*obj.xdc.n; theta_xdc = sector/obj.xdc.r;
    theta = linspace(-theta_xdc/2,theta_xdc/2,obj.xdc.n);
    yp = sin(theta)*obj.xdc.r; obj.xdc.y = yp;
    zp = cos(theta)*obj.xdc.r; obj.xdc.z = zp-max(zp);
    assert(~any(yp<min(obj.grid_vars.y_axis)),'Aperture too large for grid size.')
    assert(~any(yp>max(obj.grid_vars.y_axis)),'Aperture too large for grid size.')

    wy = obj.xdc.width*cos(theta);
    iy = [yp(:)-wy(:)/2 yp(:)+wy(:)/2];
    [~,e_ind(:,1)] = min(abs(iy(:,1)'-obj.grid_vars.y_axis'));
    [~,e_ind(:,2)] = min(abs(iy(:,2)'-obj.grid_vars.y_axis'));
    for i = 1:size(e_ind,1)-1
        if e_ind(i,2) == e_ind(i+1,1)
            e_ind(i+1,1) = e_ind(i+1,1)+1;
        end
    end
    obj.xdc.e_ind = e_ind;
    warning('Due to curvature of array, maximum depth is now %.3f',obj.input_vars.wZ+min(obj.xdc.z))
elseif strcmp(obj.xdc.type, 'linear')
    assert(isfield(obj.xdc,'pitch'),'Unidentified element pitch in obj.xdc.')
    assert(isfield(obj.xdc,'kerf'),'Unidentified element kerf in obj.xdc.')
    assert(isfield(obj.xdc,'n'),'Unidentified number of elements (n) in obj.xdc.')
    
    if ~isfield(obj.xdc,'on_elements'); obj.xdc.on_elements = 1:obj.xdc.n; end
    if ~isfield(obj.xdc,'tx_apod'); obj.xdc.tx_apod = ones(length(obj.xdc.on_elements),1); end
    if ~isfield(obj.xdc,'p_size'); obj.xdc.p_size = [1,1,1]; end
    
    obj.xdc.width = obj.xdc.pitch-obj.xdc.kerf;
    e_size = round(obj.xdc.width/obj.grid_vars.dY);
    D = obj.xdc.pitch*obj.xdc.n; obj.xdc.nD = round(D/obj.grid_vars.dY);
    e_start = round(linspace(1, obj.xdc.nD-e_size+1, obj.xdc.n));
    e_ind_uncorr = [e_start' (e_start+e_size-1)'];
    obj.xdc.e_ind = e_ind_uncorr+round((obj.grid_vars.nY/2)-mean(e_ind_uncorr(:)));
    
    assert(~any(obj.xdc.e_ind(:)<1),'Aperture too large for grid size.')
    assert(length(obj.xdc.tx_apod)==length(obj.xdc.on_elements),'Transmit apodization must match on elements.');
else
    error('Unsupported transducer type.')
end

end