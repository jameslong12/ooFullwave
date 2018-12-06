%  ooFullwave, v1.2.0
%
%  Examples using fwObj to setup and run Fullwave simulations for focused,
%  plane wave, and diverging transmits on linear arrays.
%
%  James Long 12/06/2018
%  ***Fullwave written by Gianmarco Pinton***

%% Focused transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 6e-2;                                  % Axial extent (m)
wY = 2e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',0.08,'wZ',4e-2,'td',td,'ncycles',2);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
focus = [0 0.03];                           % Focal point in [y z] (m)
sim = sim.make_xdc().focus_linear(focus);   % Call methods to calculate other parameters

%%% Show icmat, delays, and tx_apod %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close; figure('pos',[2000 100 1000 700],'color','w')
subplot(121)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)');
title('sim.xdc.icmat (single row)')

subplot(222)                                     
msz = 100;
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)');
title('sim.xdc.delays')

subplot(224)
plot(sim.xdc.on_elements,sim.xdc.tx_apod,'-r','linewidth',2); axis tight
xlabel('Element number'); ylabel('Element weight');
title('sim.xdc.tx\_apod')

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% p = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))

%% Plane transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 6e-2;                                  % Axial extent (m)
wY = 2e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',0.08,'wZ',4e-2,'td',td,'ncycles',2);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
th = 15;                                    % Angle for plane wave transmit (degrees)
focus = 10*[sind(th) cosd(th)];             % Very far focus to flatten delays
sim = sim.make_xdc().focus_linear(focus);   % Call methods to calculate other parameters

%%% Show icmat, delays, and tx_apod %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close; figure('pos',[2000 100 1000 700],'color','w')
subplot(121)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)');
title('sim.xdc.icmat (single row)')

subplot(222)                                     
msz = 100;
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)');
title('sim.xdc.delays')

subplot(224)
plot(sim.xdc.on_elements,sim.xdc.tx_apod,'-r','linewidth',2); axis tight
xlabel('Element number'); ylabel('Element weight');
title('sim.xdc.tx\_apod')

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% p = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))

%% Diverging transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 6e-2;                                  % Axial extent (m)
wY = 2e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',0.08,'wZ',4e-2,'td',td,'ncycles',2);

%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
focus = [0 -0.03];                          % Negative focus for diverging in [y z] (m)
sim = sim.make_xdc().focus_linear(focus);   % Call methods to calculate other parameters

%%% Show icmat, delays, and tx_apod %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close; figure('pos',[2000 100 1000 700],'color','w')
subplot(121)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)');
title('sim.xdc.icmat (single row)')

subplot(222)                                     
msz = 100;
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b'); axis tight
xlabel('Element number'); ylabel('Time (us)');
title('sim.xdc.delays')

subplot(224)
plot(sim.xdc.on_elements,sim.xdc.tx_apod,'-r','linewidth',2); axis tight
xlabel('Element number'); ylabel('Element weight');
title('sim.xdc.tx\_apod')

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% p = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))