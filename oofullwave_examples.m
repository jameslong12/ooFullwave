%  ooFullwave, v1.2.0
%
%  Examples using fwObj to setup and run Fullwave simulations for focused,
%  plane wave, and diverging transmits on linear arrays.
%
%  James Long 12/06/2018
%  ***Fullwave written by Gianmarco Pinton***

%% Setup fwObj for varying transmit cases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close; figure('pos',[2000 100 1200 600],'color','w')
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

%% Make changes to maps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close; figure('pos',[2000 100 1400 500],'color','w')
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
cC = 1e-3*[-15 50; -5 50; 5 50; 15 50];    % Locations of cyst centers in [y z] (m)
rC = 0.004*ones(size(cC,1),1);             % Radii of cysts (m)
zC = [0 0.025 0.075 0.1]';                 % Cyst relative impedance contrast
sim.make_speckle('nscat',50,'csr',0.05,'nC',length(rC),'cC',cC,'rC',rC,'zC',zC);

subplot(133)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.z_axis*1e3,sim.field_maps.cmap',cax);
xlabel('Lateral (mm)'); ylabel('Axial (mm)'); axis image
title('Add speckle with cysts')

%% Run simulation

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% p = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))