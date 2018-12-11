## Object oriented tools for Fullwave simulations

This repository contains an object-oriented wrapper for [Fullwave](https://gitlab.oit.duke.edu/ultrasound/fullwave2D) and an example script for usage. Fullwave is written by Gianmarco Pinton.

The workflow is as follows:
	1. Call `fwObj()` to initialize the simulation object-oriented
	2. Set transducer properties and call `make_xdc()`
	3. Define the focus and call `focus_linear()`
	4. If desired, change the field maps via `add_wall()` or `make_speckle()`
	5. Run the simulation with `do_sim()`

The simulation output is written for compatibility with [this beamforming toolset.](https://gitlab.oit.duke.edu/nbb5/Beamforming)

### Example scripts
* [oofullwave_examples.m](oofullwave_examples.m) - Example usage with varying focal configurations and simple field map changes
* More to be added in future versions

### Description of scripts
