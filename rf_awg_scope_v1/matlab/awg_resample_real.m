function realWave = awg_resample_real(wave, inputFs, targetFs)
%AWG_RESAMPLE_REAL Resample real AWG samples to the DAC sample rate.
% The FPGA receives real samples. No IQ mixer, carrier insertion, NCO, or
% RFDC DUC is performed here. Fourier interpolation is periodic because the
% FPGA plays the selected record cyclically. Output contains complete
% 512-bit RAM words (32 int16 samples). Invalid lengths are rejected;
% samples are never truncated, padded, or retimed to meet RAM alignment.
if nargin < 3, targetFs = 9e9; end
validateattributes(wave,{'numeric'},{'2d','real','finite','nonempty'});
validateattributes(inputFs,{'numeric'},{'scalar','finite','positive'});
validateattributes(targetFs,{'numeric'},{'scalar','finite','positive'});
assert(inputFs <= targetFs*(1+1e-12), ...
    '源采样率 %.9g Hz 高于 DAC 采样率 %.9g Hz；请先进行抗混叠降采样。',inputFs,targetFs);
N=size(wave,1);
ratio=targetFs/inputFs;
exactLength=N*ratio;
assert(isfinite(exactLength),'重采样点数超出数值范围；请检查源采样率及点数。');
M=round(exactLength);
assert(abs(exactLength-M)<=8*eps(exactLength), ...
    '源%d点、Fs=%.12g Hz，重采样后理论点数为%.15g，必须是整数且为32的倍数；不会自动截断或补零，请调整源播放点数或采样率。',N,inputFs,exactLength);
assert(M>=32,'重采样后至少需要32个DAC样点（一个512-bit RAM字）；请增加源波形长度。');
assert(M<=65536,'重采样后每路为%d点，超过DAC RAM上限65536点。',M);
assert(mod(M,32)==0, ...
    '重采样后每路为%d点，必须是32的倍数（一个512-bit RAM字）；不会自动截断或补零，请调整源播放点数或采样率。',M);

if inputFs==targetFs
    realWave=double(wave);
    return
end
% Evaluate the periodic Fourier series at t=m/targetFs. Passing the rounded
% M directly to interpft would instead change the duration of the whole
% record and shift every frequency. A chirp convolution evaluates the exact
% time grid for any rate ratio without constructing an enormous p/q buffer.
spectrum=fftshift(fft(double(wave),[],1),1);
firstBin=-floor(N/2);
if mod(N,2)==0
    % Split the even-length Nyquist bin between positive/negative frequency
    % so the interpolated signal remains real, including Nyquist tones.
    spectrum=[spectrum(1,:)/2; spectrum(2:end,:); spectrum(1,:)/2];
end
L=size(spectrum,1);
j=(0:L-1)'; m=(0:M-1)'; lag=(-(L-1):M-1)';
alpha=inputFs/(N*targetFs);
inputChirp=exp(1j*pi*alpha*j.^2);
outputChirp=exp(1j*pi*alpha*m.^2+2j*pi*alpha*firstBin*m)/N;
fftLength=2^nextpow2(2*L+M-2);
kernel=fft(exp(-1j*pi*alpha*lag.^2),fftLength);
realWave=zeros(M,size(wave,2));
for ch=1:size(wave,2)
    convolution=ifft(fft(spectrum(:,ch).*inputChirp,fftLength).*kernel);
    realWave(:,ch)=real(convolution(L:L+M-1).*outputChirp);
end
end
