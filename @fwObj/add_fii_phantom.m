function obj = add_fii_phantom(obj, phtm_file, el_lim, csr, symmetry)

%  Function to add scatterers to maps
%
%  Calling:
%           obj.make_speckle('nscat',15,'csr',0.05,'nC',0)
%
%  Optional parameters:
%           nscat:      Scatterers per resolution cell (15)
%           csr:        Scatterer impedance contrast (0.05)
%           nC:         Number of cysts (0)
%           rC:         Vector of cyst radii (m), length equal to nC
%           cC:         Matrix of cyst center locations in [y,z] (m), length equal to nC
%           zC:         Vector of cyst impedance contrast, length equal to nC
%
%  James Long, 12/17/2018

load(phtm_file)
if ~exist('phantom','var'); error('Variable "phantom" not found in file.'); end
if size(phantom,2) ~= 3; error('Could not find 3 dimensions to positions.'); end

if nargin < 4; symmetry = 1; end
if nargin < 3; csr = 0.05; end
if nargin < 2; el_lim = 1.5e3; warning('Using default elevation limit. Check for adequate scatterer density.'); end

%%% Restrict positions in elevation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind = abs(phantom.position(:,2)) < el_lim;
py = phantom.position(:,1); py = py(ind);
pz = phantom.position(:,3); pz = pz(ind);
amp = phantom.amplitude; amp = amp(ind);

%%% If symmetrical, duplicate phantom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if symmetry
    pz = [pz; pz];
    py = [py; -py];
    amp = [amp; amp];
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