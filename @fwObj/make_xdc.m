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
    error('Curvilinear not ready yet, bother James about it.')
    
elseif strcmp(obj.xdc.type, 'linear')
    assert(isfield(obj.xdc,'pitch'),'Unidentified element pitch in obj.xdc.')
    assert(isfield(obj.xdc,'kerf'),'Unidentified element kerf in obj.xdc.')
    assert(isfield(obj.xdc,'n'),'Unidentified number of elements (n) in obj.xdc.')
    
    if ~isfield(obj.xdc,'on_elements'); obj.xdc.on_elements = 1:obj.xdc.n; end
    if ~isfield(obj.xdc,'tx_apod'); obj.xdc.tx_apod = ones(length(obj.xdc.on_elements),1); end
    
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