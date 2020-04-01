%  ooFullwave, v2.3.0
%
%  Examples using fwObj to setup and run Fullwave simulations for focused,
%  plane wave, and diverging transmits on linear arrays. Includes examples
%  with abdominal walls and adding scatterers.
%
%  James Long 04/01/2020
%  ***Fullwave written by Gianmarco Pinton***

%% Setup fwObj for varying transmit cases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close; figure('pos',[100 100 1200 600],'color','w')
msz = 100;

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 8e-2;                                  % Axial extent (m)
wY = 6e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
sim.make_xdc();                             % Call make_xdc to set up transducer

%%% Focused transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 0.03];                           % Focal point in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat

subplot(231)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)'); title('Focused transmit'); ylim([0 20])
subplot(234)                                     
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)'); title('Focused delays')

%%% Plane transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
th = 15;                                    % Angle for plane wave transmit (degrees)
focus = 10*[sind(th) cosd(th)];             % Very far focus to flatten delays
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat

subplot(232)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)'); title('Plane transmit'); ylim([0 20])
subplot(235)                                     
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)'); title('Plane delays')

%%% Diverging transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 -0.03];                          % Negative focus for diverging in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat

subplot(233)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)'); title('Diverging transmit'); ylim([0 20])
subplot(236)                                     
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)'); title('Diverging delays')

%% Add arbitrary waveform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close; figure('pos',[100 100 1200 600],'color','w')
msz = 100;

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 8e-2;                                  % Axial extent (m)
wY = 6e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
sim.make_xdc();                             % Call make_xdc to set up transducer

%%% 2-cycle pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 0.03];                           % Focal point in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat
subplot(231)
linewidth = 2;
plot(sim.xdc.excitation_t,sim.xdc.excitation,'linewidth',linewidth)
xlabel('Time (us)'); title('2-cycle excitation'); axis tight

subplot(234)
plot(sim.xdc.pulse_t,sim.xdc.pulse,'linewidth',linewidth)
xlabel('Time (us)'); title('2-cycle pulse'); axis tight

%%% 10-cycle pulse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.input_vars.ncycles = 10;
sim.make_xdc();                             % Call make_xdc to set up transducer
focus = [0 0.03];                           % Focal point in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat
subplot(232)
linewidth = 2;
plot(sim.xdc.excitation_t,sim.xdc.excitation,'linewidth',linewidth)
xlabel('Time (us)'); title('10-cycle excitation'); axis tight

subplot(235)
plot(sim.xdc.pulse_t,sim.xdc.pulse,'linewidth',linewidth)
xlabel('Time (us)'); title('10-cycle pulse'); axis tight

%%% Chirp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flow = 1e6; fhigh = 3e6;
t = 0:sim.grid_vars.dT:6e-6; 
k = (pi/max(t))*(fhigh-flow);
phi = k*t.^2;
excitation = sin(2*pi*flow*t+phi);
sim.focus_linear(focus,[],[],excitation); 
subplot(233)
linewidth = 2;
plot(sim.xdc.excitation_t,sim.xdc.excitation,'linewidth',linewidth)
xlabel('Time (us)'); title('Chirp excitation'); axis tight

subplot(236)
plot(sim.xdc.pulse_t,sim.xdc.pulse,'linewidth',linewidth)
xlabel('Time (us)'); title('Chirp pulse'); axis tight

%% Setup fwObj to make changes to maps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close; figure('pos',[100 100 1400 500],'color','w')
cax = [1440 1640];

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 8e-2;                                  % Axial extent (m)
wY = 6e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td);

subplot(131)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.z_axis*1e3,sim.field_maps.cmap',cax);
xlabel('Lateral (mm)'); ylabel('Axial (mm)'); axis image
title('Initial')

%%% Add abdominal wall with lateral offset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wall_name = 'r75hi';                        % Mast abdominal wall name
offset = 0.01;                              % Lateral offset from center (m)
sim.add_wall(wall_name,offset);

subplot(132)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.z_axis*1e3,sim.field_maps.cmap',cax);
xlabel('Lateral (mm)'); ylabel('Axial (mm)'); axis image
title('Add abdominal wall')

%%% Add speckle and cysts of varying impedance contrasts %%%%%%%%%%%%%%%%%%
cC = 1e-3*[-10 50; 0 50; 10 50];    % Locations of cyst centers in [y z] (m)
rC = 0.004*ones(size(cC,1),1);             % Radii of cysts (m)
zC = [0 0.5 2]';                 % Cyst relative impedance contrast
sim.make_speckle('nscat',50,'csr',0.05,'nC',length(rC),'cC',cC,'rC',rC,'zC',zC);

subplot(133)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.z_axis*1e3,sim.field_maps.cmap',cax);
xlabel('Lateral (mm)'); ylabel('Axial (mm)'); axis image
title('Add speckle with cysts')

%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
rf_data = double(sim.do_sim());
fprintf('   Channel data generated in %1.2f seconds \n',toc(t))
