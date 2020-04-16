% ooFullwave, v2.3.0
%
% Demo using fwObj to set up and run a Fullwave simulation for a focused
% transmit through an abdominal wall.
%
% James Long 04/01/2020
%  ***Fullwave written by Gianmarco Pinton***

%% 1. Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
c0 = 1540;                                      % Homogeneous speed of sound
f0 = 3e6;                                       % Transmit center frequency (Hz)
wZ = 10e-2;                                      % Axial extent (m)
wY = 10e-2;                                     % Lateral extent (m)
td =(wZ+1e-2)/c0;                               % Time duration of simulation (s)
ppw = 12;
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td,'ppw',ppw);

% 2. Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'curvilinear';                   % Curvilinear or linear
sim.xdc.pitch = 0.000412;                       % Center-to-center element spacing
sim.xdc.n = 128;                                % Number of elements
sim.xdc.r = 0.04;                               % Convex radius
sim.make_xdc();                                 % Call make_xdc to set up transducer

% 3. Focus transmit at 4 cm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 0.04];                               % Focal point in [y z] (m)
sim.focus_xdc(focus);                           % Call focus_xdc to calculate icmat

% 4. Add abdominal wall and speckle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.add_wall('r75hi');                          % Mast abdominal wall name
sim.make_speckle('nscat',25);                   % Add 25 scat/res cell

% 5. Preview simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
sim.preview_sim();

%% 6. Collect channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
rf_data = double(sim.do_sim());
fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%% 7. Collect full field pressure data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
p = double(sim.do_sim(1));
fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))

%% 8. Visualize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close
maxp = max(p(:).^2);
for i = 1:5:size(p,1)
    imagesc(sim.grid_vars.y_axis*1e2,sim.grid_vars.z_axis*1e2,squeeze(p(i,:,:))'.^2/maxp,[0 1])
    title(sprintf('t = %1.2f us',sim.grid_vars.t_axis(i)*1e6))
    colormap jet
    axis image
    xlabel('Lateral (cm)')
    ylabel('Axial (cm)')
    drawnow
end

close
maxp = squeeze(max(p.^2,[],1))';
imagesc(sim.grid_vars.y_axis*1e2,sim.grid_vars.z_axis*1e2,maxp)
colormap jet
axis image
xlabel('Lateral (cm)')
ylabel('Axial (cm)')
title('Maximum intensity')
