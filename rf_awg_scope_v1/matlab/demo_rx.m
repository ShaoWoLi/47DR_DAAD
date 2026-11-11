% Standalone receive/plot demo using synthetic data; no board is needed.
% Run demo_rx after adding this folder to the MATLAB path.
projectRoot=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot,'matlab'));
rx=awg_import_ila(fullfile(projectRoot,'sim','demo','capture.csv'));
result=awg_plot(rx,0);
sgtitle('47DR synthetic capture demo (not a board measurement)');
disp('rx.iq is N-by-8 complex ADC codes; column 1 is CH0.');
