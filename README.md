## Object oriented tools for Fullwave simulations

This repository contains an object-oriented wrapper for [Fullwave](https://gitlab.oit.duke.edu/ultrasound/fullwave2D) and an example script for usage. Fullwave is written by Gianmarco Pinton. The simulation output is written for compatibility with [this beamforming toolset.](https://gitlab.oit.duke.edu/nbb5/Beamforming)

### Setup
* [fwObj()](fwObj.m) - Initialize simulation object by setting parameters keywords-style

### Methods
* [make_xdc()](make_xdc.m) - Initialize transducer properties
* [focus_linear()](focus_linear.m) - Calculate transmit focal delays and sets up initial conditions
* [add_wall()](add_wall.m) - Add abdominal wall in nearfield
* [make_speckle()](make_speckle.m) - Add scatterers to field, with option to include cysts of tunable size and scattering properties
* [make_points()](make_points.m) - Add point targets to field with varying impedance contrast 
* [add_fii_phantom()](make_points.m) - Add Field II phantom using phantom output from [ultratrack](https://github.com/mlp6/ultratrack)
* [do_sim()](do_sim.m) - Perform simulation, with option to save channel data or field pressure distribution
* [make_acq_params()](make_acq_params.m) - Convert simulation parameters to `acq_params`, necessary for use with beamforming tools

### Helper scripts
* [extract_struct.m](extract_struct.m) - Extracts structure fields as individual variables in workspace
* [focus_transmit.m](focus_transmit.m) - Calculate transmit focal delays pixel-by-pixel
* [average_icmat.m](average_icmat.m) - Perform element averaging across pixels in transmit
* [get_delays.m](get_delays.m) - Retrieve element-by-element delays in transmit

### Workflow
* Call `fwObj()` to initialize the simulation object-oriented
* Set transducer properties and call `make_xdc()`
* Define the focus and call `focus_linear()`
* If desired, change the field maps via `add_wall()` or `make_speckle()`
* Run the simulation with `do_sim()`

### Example script walkthrough
* [oofullwave_examples.m](oofullwave_examples.m) - Example usage with varying focal configurations and simple field map changes

```
%%% Create fwObj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = 1540;                                  % Homogeneous speed of sound
f0 = 2e6;                                   % Transmit center frequency (Hz)
wZ = 8e-2;                                  % Axial extent (m)
wY = 6e-2;                                  % Lateral extent (m)
td =(wZ+1e-2)/c0;                           % Time duration of simulation (s)
sim = fwObj('c0',c0,'f0',f0,'wY',wY,'wZ',wZ,'td',td);
```
First, we will call `fwObj()` to initialize the simulation object. In this example, we have specified the homogeneous speed of sound, transmit center frequency, axial and lateral extents of the field, and the time duration of simulation.

```
%%% Specify transducer and transmit parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
sim.xdc.type = 'linear';                    % Curvilinear or linear
sim.xdc.pitch = 0.000412;                   % Center-to-center element spacing
sim.xdc.kerf = 3.25e-5;                     % Interelement spacing
sim.xdc.n = 64;                             % Number of elements
sim.make_xdc();                             % Call make_xdc to set up transducer
```
Next, we will set transducer properties and call `make_xdc()` to configure the remaining properties. The transducer type, pitch, kerf, and number of elements is required.

```
%%% Focused transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 0.03];                           % Focal point in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat

%%% Plane transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
th = 15;                                    % Angle for plane wave transmit (degrees)
focus = 10*[sind(th) cosd(th)];             % Very far focus to flatten delays
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat

%%% Diverging transmit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
focus = [0 -0.03];                          % Negative focus for diverging in [y z] (m)
sim.focus_linear(focus);                    % Call focus_linear to calculate icmat
```
`focus_linear()` is called to calculate focal delays in transmit and set up the initial condition matrix (`icmat`). Plane wave transmit is achieved with a large focal distance relative to the field extent; diverging wave transmit is achieved with a negative focal depth.
The corresponding `icmat` and element-wise focal delays can be seen here:
![alt text](transmit.png)

```
%%% Add abdominal wall with lateral offset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wall_name = 'r75hi';                        % Mast abdominal wall name
offset = 0.01;                              % Lateral offset from center (m)
sim.add_wall(wall_name,offset);
```
A Mast abdominal wall can be added in the nearfield using `add_wall()`. Here, we add one with a lateral offset of 1 cm.

```
%%% Add speckle and cysts of varying impedance contrasts %%%%%%%%%%%%%%%%%%
cC = 1e-3*[-15 50; -5 50; 5 50; 15 50];    % Locations of cyst centers in [y z] (m)
rC = 0.004*ones(size(cC,1),1);             % Radii of cysts (m)
zC = [0 0.025 0.075 0.1]';                 % Cyst relative impedance contrast
sim.make_speckle('nscat',50,'csr',0.05,'nC',length(rC),'cC',cC,'rC',rC,'zC',zC);
```
Scattering and cyst targets can be added by calling `make_speckle()`. The impedance mismatch, scattering density, and cyst size and location can be adjusted. Combining the scatterers with the abdominal wall, we arrive at the following `cmap`:
![alt text](maps.png)

```
%%% Collect single transmit channel data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tic;
rf_data = double(sim.do_sim());
fprintf('   Channel data generated in %1.2f seconds \n',toc(t))
```
Finally, the simulation is run by calling `do_sim()`. Here, we collect single transmit channel data.



