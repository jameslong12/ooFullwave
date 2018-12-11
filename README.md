## Object oriented tools for Fullwave simulations

This repository contains an object-oriented wrapper for [Fullwave](https://gitlab.oit.duke.edu/ultrasound/fullwave2D) and an example script for usage. Fullwave is written by Gianmarco Pinton. The simulation output is written for compatibility with [this beamforming toolset.](https://gitlab.oit.duke.edu/nbb5/Beamforming)

### Setup
* [fwObj()](fwObj.m) - Initialize simulation object by setting parameters keywords-style

### Methods
* [make_xdc()](make_xdc.m) - Initialize transducer properties
* [focus_linear()](focus_linear.m) - Calculate transmit focal delays and sets up initial conditions
* [add_wall()](add_wall.m) - Add abdominal wall in nearfield
* [make_speckle()](make_speckle.m) - Add scatterers to field, with option to include cysts of tunable size and scattering properties
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
* More to be added in future versions

