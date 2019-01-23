function benchmark_blur(idx)

%% basic setup
cwd = pwd;

%%% Add paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('/datacommons/ultrasound/jc500/GIT/ooFullwave/'))
addpath(genpath('/datacommons/ultrasound/jc500/GIT/Beamforming/'))
fullwave_path = '/datacommons/ultrasound/jc500/GIT/fullwave2/'; addpath(genpath(fullwave_path))

frequencies = 1.4:0.4:5.0;

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = frequencies(idx)*1e6;                  % Transmit center frequency (Hz)
wZ = 8e-2;                                  % Axial extent (m)
wY = 6e-2;                                  % Lateral extent (m)
td = (2*wZ+1e-2)/c0;                        % Time duration of simulation (s)
ppw = 8;                                    % Points per wavelength
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td,'ppw',ppw,'cfl',0.5);

%%% Add abdominal wall with lateral offset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wall_name = 'r75hi';                        % Mast abdominal wall name
sim.add_wall(wall_name,0,8);

% %%% Add speckle and cysts of varying impedance contrasts %%%%%%%%%%%%%%%%%%
% cC = 1e-3*[0 40];                           % Locations of cyst centers in [y z] (m)
% rC = 0.005*ones(size(cC,1),1);              % Radii of cysts (m)
% zC = [0];                                   % Cyst relative impedance contrast
% sim.make_speckle('nscat',15,'csr',0.05,'nC',length(rC),'cC',cC,'rC',rC,'zC',zC);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 128;                             % Number of elements

z_focus = 0.06;                             % Specify depth of focus (m)
fnum = 2;                                   % Specify F-number
D = z_focus/fnum;                           % Calculate aperture size
n_on = round(D/sim.xdc.pitch);              % Calculate number of on elements
n_lines = sim.xdc.n-n_on+1;                 % Calculate number of scan lines
i = round(n_lines/2);                       % Find center line

x_focus = (1:n_lines)*sim.xdc.pitch;        % Calculate spacing of lines
x_focus = x_focus-mean(x_focus);            % Set mean to zero

%%% Collect and process channel data for center line %%%%%%%%%%%%%%%%%%%%%%
scratch_path = '/work/jc500/scratch/';
if ~exist(scratch_path, 'dir'), mkdir(scratch_path); end
tmp_path=tempname(scratch_path);
copyfile(fullwave_path,tmp_path)
mkdir(tmp_path);
cd(tmp_path)

sim.xdc.on_elements = (1:n_on)+i-1;         % Specify on elements
sim.make_xdc();                             % Call make_xdc to set up transducer
sim.xdc.focus = [x_focus(i) z_focus];       % Specify focal point (m)
sim.focus_linear(sim.xdc.focus);            % Call focus_linear to calculate icmat

t = tic;
rf_data = single(sim.do_sim(0,2));          % Perform simulation (version 2)

acq_params = sim.make_acq_params();         % Output acquisition parameters
acq_params.tx_pos = [x_focus(i) 0 0];       % Correct transmit position
acq_params.samples = size(rf_data,1);       % Update samples
rf_unfocused = rf_data;                     % Store unfocused data

bf_params.channel = 1; bf_params.z = ((1:acq_params.samples)+0*acq_params.t0)*acq_params.c/2/acq_params.fs;
acq_params.receive_fixed = 1;
acq_params.theta = 0;
bf=dynamic_receive_linear(acq_params,bf_params);
[rf_focused,z,~]=bf.beamform(rf_data);

%%% Store apodization, RF, and parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('   Channel data generated in %1.2f seconds \n',toc(t))
journal = sprintf('Channel data generated in %1.2f seconds \n',toc(t));

%%% Save data and remove temporary path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(['/datacommons/ultrasound/jc500/GIT/ooFullwave/benchmarking/test_' num2str(idx) '.mat'],'z','rf_focused','rf_unfocused','acq_params','sim','journal','-v7.3')

rmdir(tmp_path,'s');
cd(cwd)

end
