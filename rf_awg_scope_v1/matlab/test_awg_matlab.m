function test_awg_matlab
% Regression on synthetic captures; never accesses the board.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(fullfile(root,'matlab'));
folder=fullfile(root,'sim','matlab_fixtures');
expected=readmatrix(fullfile(folder,'expected.txt'));
rx=awg_import_ila(fullfile(folder,'capture.csv'),fullfile(folder,'capture.mat'));
assert(isequal(real(rx.iq),expected(:,1:8)) && isequal(imag(rx.iq),expected(:,9:16)));
assert(rx.beatCounter(5)==0,'Counter wrap test failed.');
saved=load(fullfile(folder,'capture.mat'));
assert(isequal(saved.iq,rx.iq) && saved.Fs==245760000);
for name={'gap','invalid','partial','fault','unready'}
    failed=false;
    try, awg_import_ila(fullfile(folder,[name{1} '.csv'])); catch, failed=true; end
    assert(failed,'Invalid capture accepted: %s',name{1});
end
for name={'decimal','binary'}
    alternate=awg_import_ila(fullfile(folder,[name{1} '.csv']));
    assert(isequal(alternate.iq,rx.iq),'Radix mismatch.');
end
N=1024; iq=0.25*exp(1j*2*pi/N*((0:N-1)'*(4*(1:8))));
out=fullfile(folder,'tx'); awg_export(iq,out,255);
for ch=0:7
    actual=strtrim(fileread(fullfile(out,sprintf('ch%d.hex',ch))));
    expectedHex=strtrim(fileread(fullfile(root,'waveforms','quick_all',sprintf('ch%d.hex',ch))));
    assert(strcmp(actual,expectedHex),'MATLAB/Python transmit packing differs.');
end
demo=awg_import_ila(fullfile(root,'sim','demo','capture.csv'));
set(groot,'defaultFigureVisible','off'); restore=onCleanup(@() set(groot,'defaultFigureVisible','on'));
result=awg_plot(demo,0);
assert(abs(result.peakHz-1920000)<1,'FFT peak mismatch.');
exportgraphics(gcf,fullfile(folder,'matlab_scope.png'),'Resolution',120); close(gcf);
% A mask containing CH2 only must pick the first enabled channel for plotting.
demo.channelMask=4; awg_plot(demo); close(gcf);
% Direct real-waveform path: resample an arbitrary source rate to 9 GS/s;
% there is no carrier insertion or RFDC mixer operation.
n=4096; FsIn=4e9; t=(0:n-1)'/FsIn;
wave=0.25*cos(2*pi*100e6*t);
realWave=awg_resample_real(wave,FsIn,9e9);
assert(isequal(size(realWave),[9216 1]) && isreal(realWave));
window=realWave(:,1).*hann(size(realWave,1),'periodic');
spec=abs(fft(window)); [~,peak]=max(spec(1:floor(end/2)));
peakHz=(peak-1)*9e9/numel(window);
assert(abs(peakHz-100e6)<2e6,'Direct 9 GS/s resampling peak mismatch.');
realOut=fullfile(folder,'tx_real'); packed=awg_export_real(realWave,realOut,1);
assert(isequal(size(packed.samples),[9216 8]) && packed.Fs==9e9);
hex=strtrim(fileread(fullfile(realOut,'ch0.hex')));
assert(numel(splitlines(hex))==4608 && contains(fileread(fullfile(realOut,'waveform.meta')),'sample_format 1'));
% RAM alignment must never silently truncate, pad, or retime the source.
direct=(0:63)'/100;
assert(isequal(awg_resample_real(direct,9e9),direct));
assert(size(awg_resample_real(zeros(65536,1),9e9),1)==65536);
FsIn=4.2e9; n=224; k=7;
source=0.3*cos(2*pi*k*(0:n-1)'/n);
aligned=awg_resample_real(source,FsIn);
assert(size(aligned,1)==480);
expected=0.3*cos(2*pi*(FsIn*k/n)*(0:479)'/9e9);
assert(max(abs(aligned-expected))<1e-10,'RAM alignment shifted the physical tone frequency.');
nyquist=awg_resample_real((-1).^(0:127)',4e9);
assert(max(abs(nyquist-cos(pi*(0:size(nyquist,1)-1)'*4/9)))<1e-10);
% Permit floating-point representation error only, not fractional lengths.
assert(size(awg_resample_real(zeros(128,1),4e9*(1+eps)),1)==288);
invalidLengths=[48 9e9; 33 9e9; 32 4e9; 96 4.2e9; 65568 9e9; 32 1e-300];
for k=1:size(invalidLengths,1)
    failed=false;
    try, awg_resample_real(zeros(invalidLengths(k,1),1),invalidLengths(k,2)); catch, failed=true; end
    assert(failed,'A fractional, partial-word or oversized record was accepted.');
end
for count=[16 48]
    failed=false;
    try, awg_export_real(zeros(count,1),fullfile(folder,'invalid_real'),1); catch, failed=true; end
    assert(failed,'A partial 512-bit RAM word was accepted.');
end
fprintf('PASS: direct arbitrary-Fs to 9 GS/s real TX resampling/packing, all ADC lanes/signs, radix precision, counter wrap, invalid capture rejection, MAT roundtrip and plots.\n');
fprintf('PASS: strict 32-sample RAM length validation, fractional/oversized rejection, exact time grid and Nyquist interpolation; no truncation or padding.\n');
end
