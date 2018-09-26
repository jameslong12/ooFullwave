%%% Example of ooFullwave usage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

f0 = 1e6;
fnum = 1;
focus = [0 0.03];
D = focus(2)/fnum; % match simulation width to aperture width

%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim = fwObj('f0',f0,'wY',D,'wZ',4e-2, 'td', 3e-5);

%%% Specify transducer parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.n = 128;                % Number of elements
sim.xdc.type = 'linear';        % Curvilinear or linear
sim.xdc.pitch = 0.000412;       % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;         % Interelement spacing
sim = make_xdc(sim);            % Call to calculate other parameters

%%% Focus transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim = focus_linear(sim, focus);

%%% Create speckle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
rf_data = double(sim.do_sim());
fprintf('   Channel data generated in %1.2f seconds \n',toc(t))

%%% Collect full pressure field data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
pressure = double(sim.do_sim(1));
fprintf('   Field pressure data generated in %1.2f seconds \n',toc(t))