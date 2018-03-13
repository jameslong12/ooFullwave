classdef fwObj < handle
    
    %  Create simulation object of class fwObj to perform Fullwave simulations
    %  (created by Gianmarco Pinton). Assumes path to Fullwave tools have
    %  already been added.
    %
    %  Initialization:
    %           obj = fwObj(varargin)
    %
    %  Optional parameters (default):
    %           f0              - Center frequency in MHz (1)
    %           ncycles         - Excitation cycles (2)
    %           c0              - Speed of sound in m/s (1540)
    %           td              - Time duration of simulation in s (40e-6)
    %           p0              - Pressure amplitude of transmit in Pa (1e5)
    %           ppw             - Spatial points per wavelength (15)
    %           cfl             - Courant-Friedrichs-Levi number (0.4)
    %           wY              - Lateral span of simulation in m (5e-2)
    %           wZ              - Depth of simulation in m (5e-2)
    %           rho             - Density in kg/m^3 (1000)
    %           atten           - Attenuation in dB/MHz/cm (0)
    %           bovera          - Non-linearity parameter (-2)
    %
    %  Return:
    %           obj             - Simulation object with properties:
    %                               input_vars:     Input variables
    %                               grid_vars:      Grid variables
    %                               field_maps:     Field maps (cmap, rhomap,
    %                                               attenmap, boveramap)
    %
    %  Methods:
    %           make_xdc        - Generate transducer properties based on
    %                             transducer type and focusing, returns xdc
    %                             property of obj
    %           gen_speckle     - Generate a field of scatters by changing
    %                             cmap, with an option to add lesions
    %           do_sim          - Perform the simulation and return the
    %                             channel data
    %
    %  James Long, 03/09/2018
    
    properties
        input_vars
        grid_vars
        field_maps
        xdc
    end
    
    methods
        
        %%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = fwObj(varargin)
            
            p = inputParser;
            %%% Add defaults for optional requirements %%%%%%%%%%%%%%%%%%%%
            addOptional(p,'c0',1540)
            addOptional(p,'td',100e-6)
            addOptional(p,'p0',1e5)
            addOptional(p,'ppw',15)
            addOptional(p,'cfl',0.4)
            addOptional(p,'wY',10e-2)
            addOptional(p,'wZ',6e-2)
            addOptional(p,'rho',1000)
            addOptional(p,'atten',0)
            addOptional(p,'bovera',-2)
            addOptional(p,'f0',1)
            addOptional(p,'ncycles',2)
            
            %%% Parse inputs and extract variables from p %%%%%%%%%%%%%%%%%
            p.parse(varargin{:})
            var_struct = p.Results;
            assignments = extract_struct(var_struct);
            for i = 1:length(assignments)
                eval(assignments{i})
            end
            
            %%% Grid size calculations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            omega0 = 2*pi*f0*1e6;
            lambda = c0/omega0*2*pi;
            nY = round(wY/lambda*ppw);
            nZ = round(wZ/lambda*ppw);
            nT = round(td*c0/lambda*ppw/cfl);
            dY = c0/omega0*2*pi/ppw;
            dZ = c0/omega0*2*pi/ppw;
            dT = dY/c0*cfl;
            t_axis = 0:dT:(nT-1)*dT;
            z_axis = 0:dZ:(nZ-1)*dZ;
            y_axis = 0:dY:(nY-1)*dY; y_axis = y_axis - mean(y_axis);
            
            %%% Generate field maps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cmap = ones(nY,nZ)*c0;   % speed of sound map (m/s)
            rhomap = ones(nY,nZ)*rho; % density map (kg/m^3)
            attenmap = ones(nY,nZ)*atten;    % attenuation map (dB/MHz/cm)
            boveramap = ones(nY,nZ)*bovera;    % nonlinearity map
            
            %%% Package into structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.input_vars = struct('c0',c0,...
                'td',td,...
                'p0',p0,...
                'ncycles',ncycles,...
                'ppw',ppw,...
                'cfl',cfl,...
                'wY',wY,...
                'wZ',wZ,...
                'rho',rho,...
                'atten',atten,...
                'bovera',bovera,...
                'f0',f0,...
                'omega0',omega0,...
                'lambda',lambda);
            
            obj.grid_vars = struct('nY',nY,...
                'nZ',nZ,...
                'nT',nT,...
                'dY',dY,...
                'dZ',dZ,...
                'dT',dT,...
                'y_axis',y_axis,...
                'z_axis',z_axis,...
                't_axis',t_axis);
            
            obj.field_maps = struct('cmap',cmap,...
                'cmapi',cmap,...
                'rhomap',rhomap,...
                'rhomapi',rhomap,...
                'attenmap',attenmap,...
                'attenmapi',attenmap,...
                'boveramap',boveramap,...
                'boveramapi',boveramap);
            
        end
        
        obj = make_xdc(obj, tx_params);
        obj = gen_speckle(obj, sc_params);
        show_map(obj, map_name);
        rf = do_sim(obj, field_flag);
        
    end
    
end