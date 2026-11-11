% Run from any working directory. Generate eight periodic complex tones.
projectRoot=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot,'matlab'));
Fs=245760000;
N=16384;
sample=(0:N-1)';
iq=0.25*exp(1j*2*pi/N*(sample*(128*(1:8)))); % N-by-8, columns CH0..CH7
tx=awg_export(iq,fullfile(projectRoot,'waveforms','matlab_tone'),255);
disp('Load the resulting directory using Vivado awg::load, then awg::start.');
