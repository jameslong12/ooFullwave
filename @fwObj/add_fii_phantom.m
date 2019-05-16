function obj = add_fii_phantom(obj, phtm_file, symmetry, el_lim, csr, fnum)

%  Method to add scatterers to maps from phantom files in format used in
%  Field II. Adds scatterers using impedance flow method. Written for use
%  with Mark Palmeri's ultratrack tools.
%
%  Calling:
%           obj.add_fii_phantom('phtm_file.mat', 1.5-3, 0.05, 2)
%
%  Parameters:
%           phtm_file:      Path to phantom file. File must be .mat
%                           containing "phantom" structure with fields
%                           "position" and "amplitude" (standard output
%                           from Mark Palmeri's ultratrack tools)
%           symmetry:       Symmetry of phantom ('q','h','none')
%           el_lim:         Elevational limit [m] (default: 1.5e-3)
%           csr:            Standard deviation of scatterer impedance
%                           contrast (default: 0.05)
%           fnum:           (Optional) Transmit F-number used to calculate
%                           scatterers per resolution cell
%
%  James Long, 12/17/2018

load(phtm_file)
if ~exist('phantom','var'); error('Variable "phantom" not found in file.'); end
if size(phantom.position,2) ~= 3; error('Could not find 3 dimensions to positions.'); end

if nargin < 5; csr = 0.05; end
if nargin < 4; el_lim = 1.5e-3; warning('Using default elevation limit. Check for adequate scatterer density.'); end

switch symmetry
    case 'q'
        %%% Restrict positions in all dimensions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ind = abs(phantom.position(:,2)) < el_lim; % elevation
        py = phantom.position(:,1); py = py(ind);
        pz = phantom.position(:,3); pz = pz(ind);
        amp = phantom.amplitude; amp = amp(ind);
        
        ind = abs(phantom.position(:,1)) < obj.input_vars.wY/2; % lateral
        py = phantom.position(:,1); py = py(ind);
        pz = phantom.position(:,3); pz = pz(ind);
        amp = phantom.amplitude; amp = amp(ind);
        
        ind = phantom.position(:,3) < obj.input_vars.wZ; % axial
        py = phantom.position(:,1); py = py(ind);
        pz = phantom.position(:,3); pz = pz(ind);
        amp = phantom.amplitude; amp = amp(ind);
        
        pz = [pz; pz];
        py = [py; -py];
        amp = [amp; amp];
        
        %%% If F-number known, calculate scatterers per resolution cell %%%%%%%%%%%
        if exist('fnum','var')
            scat_density = length(py)/(abs(max(py)*max(pz)));
            ry = obj.input_vars.lambda*fnum; rz = obj.input_vars.ncycles*obj.input_vars.lambda/2;
            rescell = ry*rz; nscat_cell = scat_density*rescell;
            fprintf('   Scatterers per resolution cell = %1.1f',nscat_cell)
            
            %%% Optional code to visualize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %scatter(py,pz,0.5,'.r'); axis image; title(sprintf('n_{scat per cell} = %1.1f',nscat_cell))
        end
    case 'none'
        %%% Restrict positions in all dimensions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ind = abs(phantom.position(:,2)) < el_lim; % elevation
        py = phantom.position(:,1); py = py(ind);
        pz = phantom.position(:,3); pz = pz(ind);
        amp = phantom.amplitude; amp = amp(ind);
        
        ind = abs(py) < 0.99*obj.input_vars.wY/2; % lateral
        py = py(ind);
        pz = pz(ind);
        amp = amp(ind);
        
        ind = pz < 0.99*obj.input_vars.wZ; % axial
        py = py(ind);
        pz = pz(ind);
        amp = amp(ind);
        
        %%% If F-number known, calculate scatterers per resolution cell %%%%%%%%%%%
        if exist('fnum','var')
            scat_density = length(py)/(abs(range(py)*range(pz)));
            ry = obj.input_vars.lambda*fnum; rz = obj.input_vars.ncycles*obj.input_vars.lambda/2;
            rescell = ry*rz; nscat_cell = scat_density*rescell;
            fprintf('   Scatterers per resolution cell = %1.1f\n',nscat_cell)
            
            %%% Optional code to visualize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %scatter(py,pz,0.5,'.r'); axis image; title(sprintf('n_{scat per cell} = %1.1f',nscat_cell))
        end
end

%%% Add scatterers using impedance flow %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scat_mask = zeros(size(obj.field_maps.cmap));
iy = interp1(obj.grid_vars.y_axis,1:length(obj.grid_vars.y_axis),py);
iz = interp1(obj.grid_vars.z_axis,1:length(obj.grid_vars.z_axis),pz);
for i = 1:length(iy)
    iy1 = floor(iy(i)); iy2 = ceil(iy(i));
    iz1 = floor(iz(i)); iz2 = ceil(iz(i));
    
    vy1 = abs(iy2-iy(i)); vy2 = abs(iy1-iy(i));
    vz1 = abs(iz2-iz(i)); vz2 = abs(iz1-iz(i));
    
    scat_mask(iy1,iz1) = amp(i)*csr*vy1*vz1;
    scat_mask(iy1,iz2) = amp(i)*csr*vy1*vz2;
    scat_mask(iy2,iz1) = amp(i)*csr*vy2*vz1;
    scat_mask(iy2,iz2) = amp(i)*csr*vy2*vz2;
end
obj.field_maps.cmap = obj.field_maps.cmap-scat_mask.*obj.input_vars.c0;