function obj = make_speckle(obj, sc_params)

%  Function to create transducer related fields
%
%  Calling:
%           obj.make_speckle(sc_params)
%
%  Parameters:
%           sc_params       - Structure of scatterer parameters
%                               n_scat:     Scatterers per resolution cell (25)
%                               csr:        Scatterer impedance contrast (0.05)
%                               n_lesion:   Number of lesions (0)
%                               r_lesion:   Vector of lesion radii, length
%                                           equal to n_lesion
%                               c_lesion:   Matrix of lesion center locations
%                                           in [y,z], length equal to n_lesion
%
%  Code inherited from Nick Bottenus, function compiled by James Long, 03/10/2018

%%% Extract fields from sc_params and set defaults %%%%%%%%%%%%%%%%%%%%%%%%
if exist('sc_params','var')
    assignments = extract_struct(sc_params);
    for i = 1:length(assignments)
        eval(assignments{i});
    end
end
if ~exist('n_scat','var'), n_scat = 25; end
if ~exist('csr','var'), csr = 0.05; end
if ~exist('n_lesion','var'), n_lesion = 0; end

%%% Calculate resolution cell using input variables %%%%%%%%%%%%%%%%%%%%%%%
res_cell = rescell2d(obj.input_vars.c0, obj.input_vars.omega0, obj.input_vars.wZ/2,...
    obj.input_vars.wY, obj.input_vars.ncycles, obj.input_vars.dY,...
    obj.input_vars.dZ);

%%% Randomly place scatterers according to density %%%%%%%%%%%%%%%%%%%%%%%%
scat_density = n_scat/res_cell;
cscatmap = rand(obj.grid_vars.nY, obj.grid_vars.nZ);
cscatmap(cscatmap > scat_density) = 0;
cscatmap = cscatmap/scat_density;

%%% Create lesions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if n_lesion
    if size(c_lesion,1) ~= n_lesion || size(r_lesion,1) ~= n_lesion
        error('r_lesion and c_lesion must be the same length as n_lesion.')
    end
    for idx = 1:n_lesion
        [z_int, y_int] = meshgrid(obj.grid_vars.z_axis, obj.grid_vars.y_axis);
        lesion_mask = (y_int-c_lesion(idx,1)).^2+(z_int-c_lesion(idx,2)).^2 < r_lesion(idx).^2;
        cscatmap(lesion_mask) = 0;
    end
end

%%% Superimpose original cmap and cscatmap %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.field_maps.cmap = obj.field_maps.cmap-cscatmap*csr*obj.input_vars.c0;

end