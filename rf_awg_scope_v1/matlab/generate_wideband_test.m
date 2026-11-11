% Generate a deterministic, single-channel wideband complex-baseband test.
root=fileparts(fileparts(mfilename('fullpath')));
outDir=fullfile(root,'waveforms','wideband_80m_ch0');
if ~isfolder(outDir), mkdir(outDir); end

Fs=245.76e6;
N=16384;
occupiedBandwidth=80e6;
binSpacing=Fs/N;
edgeBin=floor((occupiedBandwidth/2)/binSpacing);
bins=(-edgeBin:edgeBin).';
rng(4701,'twister');
symbols=exp(1j*(pi/2)*randi([0 3],numel(bins),1));
spectrum=zeros(N,1);
indices=mod(bins,N)+1;
spectrum(indices)=symbols;
iq=ifft(spectrum)*N/numel(bins);
iq=iq*(0.7/max(max(abs(real(iq))),max(abs(imag(iq)))));

assert(mod(N,4)==0 && max(abs(real(iq)))<=0.700001 && max(abs(imag(iq)))<=0.700001);
save(fullfile(outDir,'wideband_80m_ch0.mat'),'iq','Fs','occupiedBandwidth','N','-v7');
writematrix([real(iq),imag(iq)],fullfile(outDir,'wideband_80m_ch0.csv'));

fprintf('Saved %d CH0 complex samples at %.2f MS/s; occupied bandwidth %.2f MHz.\n', ...
    N,Fs/1e6,occupiedBandwidth/1e6);
fprintf('I peak %.6f, Q peak %.6f, complex peak %.6f.\n', ...
    max(abs(real(iq))),max(abs(imag(iq))),max(abs(iq)));
fprintf('MAT: %s\nCSV: %s\n', ...
    fullfile(outDir,'wideband_80m_ch0.mat'), ...
    fullfile(outDir,'wideband_80m_ch0.csv'));
