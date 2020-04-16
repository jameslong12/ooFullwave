function obj = focus_xdc(obj, focus, fc, fbw, excitation, bwr, tpe)

%  Function to create transmit related fields. Must call obj.make_xdc()
%  prior to use.
%
%  Calling:
%           obj.focus_xdc(focus)
%
%  Parameters:
%           focus           - Focal point in [y z] (m)
%           fc              - Center frequency of transducer (Hz) [obj.input_vars.f0]
%           fbw             - Fractional bandwidth of transducer [0.8]
%           excitation      - Vector of excitation in time
%           bwr             - Fractional bandwidth reference level [-6 dB]
%           tpe             - Cutoff for trailing pulse envelope [-40 dB]
%
%  Returns:
%           obj.xdc.inmap   - Input map for initial conditions
%           obj.xdc.incoords- Paired coordinates of input and initial
%                             conditions
%           obj.xdc.icmat   - Initial condition matrix for wave form time
%                             trace
%           obj.xdc.out     - Element positions in [x y z] for beamforming
%           obj.xdc.delays  - Time delays on elements in transmit
%           obj.xdc.t0      - Time of first time index (s) for beamforming
%
%  James Long 12/06/2018

if ~exist('fc','var')||isempty(fc), fc = obj.input_vars.f0; end
if ~exist('fbw','var')||isempty(fbw), fbw = 0.8; end
if ~exist('bwr','var')||isempty(bwr), bwr=-6; end
if ~exist('tpe','var')||isempty(tpe), tpe=-40; end

if strcmp(obj.xdc.type, 'curvilinear')