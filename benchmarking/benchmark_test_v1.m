% benchmark_test_v1

%% basic setup
clear

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

% close; figure('pos',[2000 100 1200 600],'color','w')
% imagesc(sim.grid_vars.y_axis*1e3,sim.grid_vars.z_axis*1e3,sim.field_maps.cmap',cax); hold on; axis image
% for i = 1:length(x_focus)
%     plot([x_focus(i) x_focus(i)]*1e3,[-100 100],'-r'); hold on
% end
% xlim([min(sim.grid_vars.y_axis*1e3) max(sim.grid_vars.y_axis*1e3)])
% ylim([min(sim.grid_vars.z_axis*1e3) max(sim.grid_vars.z_axis*1e3)])
% xlabel('Lateral (mm)'); ylabel('Axial (mm)');

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Walk aperture %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:n_lines
    sim.xdc.on_elements = (1:n_on)+i-1;     % Specify on elements
    sim.make_xdc();                         % Call make_xdc to set up transducer
    focus = [x_focus(i) z_focus];           % Specify focal point (m)
    sim.focus_linear(focus);                % Call focus_linear to calculate icmat
    
    t = tic;
    rf_data(:,:,i) = single(sim.do_sim());  % Perform simulation
    acq_params(i) = sim.make_acq_params();  % Output acquisition parameters
    acq_params(i).tx_pos = [x_focus(i) 0 0];% Correct transmit position
    journal{i} = sprintf('Channel data for line %d of %d generated in %1.2f seconds \n',i,n_lines,toc(t));
end
save('/datacommons/ultrasound/jc500/GIT/ooFullwave/benchmarking/fw1.mat','rf_data','acq_params','sim','-v7.3')
