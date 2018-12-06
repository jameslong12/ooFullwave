%% Focused transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f0 = 2e6;
sim = fwObj('f0',f0,'wY',0.08,'wZ',4e-2, 'td', 4e-5);

%%% Specify transducer parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';            % Curvilinear or linear
sim.xdc.pitch = 0.000412;           % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;             % Interelement spacing
sim.xdc.n = 64;                     % Number of elements
sim.xdc.on_elements = 12:32;        % On elements
sim = make_xdc(sim);                % Call to calculate other parameters

%%% Focus transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 0.03];                   % Focal point in [y z] (m)
sim = focus_linear(sim, focus);     % Call to calculate delays and icmat

close; figure('pos',[2000 100 1000 700],'color','w')
c0 = sim.input_vars.c0;

subplot(121)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)');
title('sim.xdc.icmat (single row)')

subplot(122)
msz = 100;
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b')
xlabel('Element number'); ylabel('Time (us)');
title('sim.xdc.delays')

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% pressure = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))
% 
% for idx = 1:10:size(pressure,1)
%     imagesc(sim.grid_vars.y_axis,sim.grid_vars.z_axis,squeeze(pressure(idx,:,:))',[0 1e5])
%     axis image
%     drawnow
%     pause(0.1)
% end

%% Plane transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f0 = 2e6;
sim = fwObj('f0',f0,'wY',0.08,'wZ',4e-2, 'td', 4e-5);

%%% Specify transducer parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';            % Curvilinear or linear
sim.xdc.pitch = 0.000412;           % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;             % Interelement spacing
sim.xdc.n = 64;                     % Number of elements
sim.xdc.on_elements = 12:32;        % On elements (default = 1:sim.xdc.n)
sim = make_xdc(sim);                % Call to calculate other parameters

%%% Focus transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
th = 15;                            % Angle for plane wave transmit (degrees)
focus = 10*[sind(th) cosd(th)];     % Very far focus to flatten delays
sim = focus_linear(sim, focus);     % Call to calculate delays and icmat

close; figure('pos',[2000 100 1000 700],'color','w')
c0 = sim.input_vars.c0;

subplot(121)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)');
title('sim.xdc.icmat (single row)')

subplot(122)
msz = 100;
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b')
xlabel('Element number'); ylabel('Time (us)');
title('sim.xdc.delays')

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% pressure = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))
% 
% for idx = 1:10:size(pressure,1)
%     imagesc(sim.grid_vars.y_axis,sim.grid_vars.z_axis,squeeze(pressure(idx,:,:))',[0 1e5])
%     axis image
%     drawnow
%     pause(0.1)
% end

%% Diverging transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f0 = 2e6;
sim = fwObj('f0',f0,'wY',0.08,'wZ',4e-2, 'td', 4e-5);

%%% Specify transducer parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';            % Curvilinear or linear
sim.xdc.pitch = 0.000412;           % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;             % Interelement spacing
sim.xdc.n = 64;                     % Number of elements
sim.xdc.on_elements = 12:32;        % On elements (default = 1:sim.xdc.n)
sim = make_xdc(sim);                % Call to calculate other parameters

%%% Focus transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 -0.03];                  % Negative focus for diverging in [y z] (m)
sim = focus_linear(sim, focus);     % Call to calculate delays and icmat

close; figure('pos',[2000 100 1000 700],'color','w')
c0 = sim.input_vars.c0;

subplot(121)
imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.t_axis*1e6,sim.xdc.icmat(1:sim.grid_vars.nY,:)');
xlabel('Lateral (mm)'); ylabel('Time (us)');
title('sim.xdc.icmat (single row)')

subplot(122)
msz = 100;
scatter(sim.xdc.on_elements,sim.xdc.delays*1e6,msz,'.b')
xlabel('Element number'); ylabel('Time (us)');
title('sim.xdc.delays')

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% rf_data = double(sim.do_sim());
% fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t = tic;
% pressure = double(sim.do_sim(1));
% fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))
% 
% for idx = 1:10:size(pressure,1)
%     imagesc(sim.grid_vars.y_axis,sim.grid_vars.z_axis,squeeze(pressure(idx,:,:))',[0 1e5])
%     axis image
%     drawnow
%     pause(0.1)
% end