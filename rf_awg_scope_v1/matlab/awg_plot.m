function result=awg_plot(rx, channel, firstSample, count)
%AWG_PLOT Time-domain I/Q/envelope and full-record Hann-window complex FFT.
% channel uses board numbering 0..7. No Signal Processing Toolbox required.
if nargin<2, channel=find(bitget(uint8(rx.channelMask),1:8),1)-1; end
if nargin<3, firstSample=1; end
if nargin<4, count=min(1024,size(rx.iq,1)-firstSample+1); end
validateattributes(channel,{'numeric'},{'scalar','integer','>=',0,'<=',7});
assert(bitget(uint8(rx.channelMask),channel+1),'This channel was not validated.');
n=size(rx.iq,1);
validateattributes(firstSample,{'numeric'},{'scalar','integer','>=',1,'<=',n});
validateattributes(count,{'numeric'},{'scalar','integer','positive'});
idx=firstSample:min(n,firstSample+count-1); z=rx.iq(:,channel+1);
w=0.5-0.5*cos(2*pi*(0:n-1)'/(n-1));
f=(-floor(n/2):ceil(n/2)-1)'*rx.Fs/n;
db=20*log10(max(abs(fftshift(fft(z.*w)))/sum(w)/32768,1e-15));
[peak,k]=max(db);
figure('Name',sprintf('47DR CH%d',channel));
subplot(2,1,1); plot((idx-1)/rx.Fs*1e6,real(z(idx)), ...
    (idx-1)/rx.Fs*1e6,imag(z(idx)),(idx-1)/rx.Fs*1e6,abs(z(idx)));
grid on; xlabel('Time / us'); ylabel('ADC code'); legend('I','Q','Envelope');
title(sprintf('CH%d | Fs %.2f MS/s | %d samples',channel,rx.Fs/1e6,n));
subplot(2,1,2); plot(f/1e6,db); grid on;
xlabel('Complex baseband frequency / MHz'); ylabel('dB relative to digital full scale');
title(sprintf('Full-record Hann FFT | bin %.3f kHz | peak %.6f MHz',rx.Fs/n/1e3,f(k)/1e6));
result=struct('frequencyHz',f,'spectrumDb',db,'peakHz',f(k),'peakDb',peak);
end
