% benchmark_test_v2

%% basic setup
clear
cwd = pwd;

%%% Add paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('/datacommons/ultrasound/jc500/GIT/ooFullwave/'))
addpath(genpath('/datacommons/ultrasound/jc500/GIT/Beamforming/'))
fullwave_path = '/datacommons/ultrasound/jc500/GIT/fullwave2/';

scratch_path = '/work/jc500/scratch/';
if ~exist(scratch_path, 'dir'), mkdir(scratch_path); end
tmp_path=tempname(scratch_path);
copyfile(fullwave_path,tmp_path)
mkdir(tmp_path);
cd(tmp_path)

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 1e6;                                   % Transmit center frequency (Hz)
wZ = 5e-2;                                  % Axial extent (m)
wY = 3e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td);

%%% Add abdominal wall with lateral offset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wall_name = 'r75hi';                        % Mast abdominal wall name
sim.add_wall(wall_name);
cax = [1440 1640];

%%% Add speckle and cysts of varying impedance contrasts %%%%%%%%%%%%%%%%%%
cC = 1e-3*[0 40];                           % Locations of cyst centers in [y z] (m)
rC = 0.005*ones(size(cC,1),1);              % Radii of cysts (m)
zC = [0];                                   % Cyst relative impedance contrast
sim.make_speckle('nscat',25,'csr',0.05,'nC',length(rC),'cC',cC,'rC',rC,'zC',zC);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements

z_focus = 0.04;                             % Specify depth of focus (m)
fnum = 2.5;                                 % Specify F-number
D = z_focus/fnum;                           % Calculate aperture size
n_on = round(D/sim.xdc.pitch);              % Calculate number of on elements
n_lines = sim.xdc.n-n_on+1;                 % Calculate number of scan lines

x_focus = (1:n_lines)*sim.xdc.pitch;        % Calculate spacing of lines
x_focus = x_focus-mean(x_focus);            % Set mean to zero

%%% Collect and process channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Walk aperture %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:n_lines
    sim.xdc.on_elements = (1:n_on)+i-1;     % Specify on elements
    sim.make_xdc();                         % Call make_xdc to set up transducer
    sim.xdc.focus = [x_focus(i) z_focus];   % Specify focal point (m)
    sim.focus_linear(sim.xdc.focus);        % Call focus_linear to calculate icmat
    
    t = tic;
    rf_data = single(sim.do_sim(0,2));      % Perform simulation (version 2)
    acq_params = sim.make_acq_params();     % Output acquisition parameters
    acq_params.tx_pos = [x_focus(i) 0 0];   % Correct transmit position
    rf_unfocused(:,:,i) = rf_data;          % Store unfocused data
    
    bf_params.channel = 1; bf_params.z = ((1:acq_params.samples)+0*acq_params.t0)*acq_params.c/2/acq_params.fs;
    acq_params.receive_fixed = 1; %acq_params.t0 = acq_params.t0/2;
    acq_params.theta = 0;
    bf=dynamic_receive_linear(acq_params,bf_params);
    [rf_focused,z,x(i)]=bf.beamform(rf_data);
    
    % Store apodization, RF, and parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rf(:,:,i) = rf_focused(:,sim.xdc.on_elements);
    params(i) = acq_params;
    times = toc(t);
    fprintf('   Channel data for line %d of %d generated in %1.2f seconds \n',i,n_lines,toc(t))
    journal{i} = sprintf('Channel data for line %d of %d generated in %1.2f seconds \n',i,n_lines,toc(t));
end

%%% Save data and remove temporary path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save('/datacommons/ultrasound/jc500/GIT/ooFullwave/benchmarking/fw1.mat','rf','rf_unfocused','params','sim','journal''times','-v7.3')
rmdir(tmp_path,'s');
cd(cwd)