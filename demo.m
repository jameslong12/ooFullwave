% ooFullwave, v2.3.0
%
% Demo using fwObj to set up and run a Fullwave simulation for a focused
% transmit through an abdominal wall.
%
% James Long 04/01/2020
%  ***Fullwave written by Gianmarco Pinton***

%% 1. Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 1e6;                                   % Transmit center frequency (Hz)
wZ = 6e-2;                                  % Axial extent (m)
wY = 4e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td);

%% 2. Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
sim.make_xdc();                             % Call make_xdc to set up transducer

%% 3. Focus transmit at 4 cm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 0.04];                           % Focal point in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat

%% 4. Add abdominal wall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wall_name = 'r75hi';                        % Mast abdominal wall name
sim.add_wall(wall_name);

%% 5. Preview simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
% sim.preview_sim()

%% 6. Collect channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
rf_data = double(sim.do_sim());
fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%% 7. Collect full field pressure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
% sim.xdc.p_size = [1 1 1];
p = double(sim.do_sim(1));
fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))
