% Generate a four-channel real-valued OFDM frame for the 9 GS/s AWG GUI.
% Columns map to DAC0, DAC1, DAC2, DAC3 when those four channels are selected.
Fs = 9e9;
Nfft = 1024;
cpLength = 128;
symbolCount = 8;
sampleCount = symbolCount * (Nfft + cpLength); % 9216, divisible by 32
subcarrierSpacingHz = Fs / Nfft;
targetBandwidthHz = [250e6 500e6 1e9 1.5e9];

% Use an even number of contiguous active tones, with DC left empty.
activeToneCount = 2 * round(targetBandwidthHz / subcarrierSpacingHz / 2);
bandwidthHz = activeToneCount * subcarrierSpacingHz;
assert(sampleCount <= 65536 && mod(sampleCount, 32) == 0);
assert(all(activeToneCount < Nfft - 2));

rng(4704, 'twister');
waveform = zeros(sampleCount, 4);
for channel = 1:4
    positiveToneCount = activeToneCount(channel) / 2;
    output = zeros(sampleCount, 1);
    for symbol = 1:symbolCount
        % QPSK values on positive-frequency tones; conjugate symmetry makes
        % the IFFT output real for the direct real-sample DAC path.
        bits = randi([0 1], positiveToneCount, 2);
        qpsk = ((1 - 2*bits(:,1)) + 1j*(1 - 2*bits(:,2))) / sqrt(2);
        spectrum = zeros(Nfft, 1);
        positiveBins = (2:positiveToneCount+1).';
        negativeBins = (Nfft-positiveToneCount+1:Nfft).';
        spectrum(positiveBins) = qpsk;
        spectrum(negativeBins) = conj(flipud(qpsk));
        useful = real(ifft(spectrum) * sqrt(Nfft));
        frame = [useful(end-cpLength+1:end); useful];
        first = (symbol-1) * (Nfft+cpLength) + 1;
        output(first:first+numel(frame)-1) = frame;
    end
    peak = max(abs(output));
    assert(peak > 0);
    waveform(:,channel) = 0.25 * output / peak;
end

channelNames = {'DAC0','DAC1','DAC2','DAC3'};
savePath = fullfile(fileparts(mfilename('fullpath')), '..', 'waveforms', ...
    'ofdm_4ch_different_bandwidth.mat');
savePath = char(java.io.File(savePath).getCanonicalPath());
save(savePath, 'waveform', 'Fs', 'bandwidthHz', 'targetBandwidthHz', ...
    'activeToneCount', 'subcarrierSpacingHz', 'Nfft', 'cpLength', ...
    'symbolCount', 'sampleCount', 'channelNames');

fprintf('Saved 4-channel OFDM waveform: %s\n', savePath);
fprintf('Fs = %.3f GS/s, samples/channel = %d, subcarrier spacing = %.6f MHz\n', ...
    Fs/1e9, sampleCount, subcarrierSpacingHz/1e6);
for channel = 1:4
    fprintf('%s: target %.3f MHz, occupied %.6f MHz, active tones %d, peak %.3f\n', ...
        channelNames{channel}, targetBandwidthHz(channel)/1e6, ...
        bandwidthHz(channel)/1e6, activeToneCount(channel), ...
        max(abs(waveform(:,channel))));
end

figure('Name','4-channel OFDM waveform');
tiledlayout(4,2,'TileSpacing','compact','Padding','compact');
for channel = 1:4
    nexttile;
    plot((0:sampleCount-1)'/Fs*1e6, waveform(:,channel));
    grid on; xlabel('Time / us'); ylabel('Amplitude');
    title(sprintf('%s, occupied bandwidth %.1f MHz', ...
        channelNames{channel}, bandwidthHz(channel)/1e6));
    nexttile;
    nfftSpectrum = 2^nextpow2(sampleCount);
    spectrumDb = 20*log10(max(abs(fftshift(fft(waveform(:,channel),nfftSpectrum))) / ...
        max(abs(fft(waveform(:,channel),nfftSpectrum))), 1e-12));
    frequencyMHz = (-nfftSpectrum/2:nfftSpectrum/2-1)' * Fs/nfftSpectrum/1e6;
    plot(frequencyMHz, spectrumDb);
    grid on; xlim([-2000 2000]); ylim([-100 5]);
    xlabel('Frequency / MHz'); ylabel('Relative dB');
    title(sprintf('%s spectrum',channelNames{channel}));
end
