function realWave = awg_iq_to_real(wave,inputFs,~,amplitude)
%AWG_IQ_TO_REAL Compatibility wrapper for the direct real-waveform path.
% The old implementation inserted a 1.5 GHz carrier. It now only performs
% periodic resampling; complex IQ input is deliberately rejected.
if nargin<4 || isempty(amplitude), amplitude=1; end
validateattributes(wave,{'numeric'},{'2d','real','finite','nonempty'});
validateattributes(amplitude,{'numeric'},{'scalar','finite','>',0,'<=',1});
realWave=amplitude*awg_resample_real(wave,inputFs,9e9);
end
