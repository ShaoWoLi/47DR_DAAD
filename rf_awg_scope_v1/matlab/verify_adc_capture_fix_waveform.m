function verify_adc_capture_fix_waveform
% Verify and show the actual board capture through the production UI importer.
root=fileparts(fileparts(mfilename('fullpath')));
csv=fullfile(root,'app_data','captures','adc_ch2_capfix_20261110.csv');
app=AWGScopeApp('off'); app.ShowAlerts=false;
cleanup=onCleanup(@() delete(app));
app.loadCapture(csv);
assert(app.Rx.Fs==5e9 && app.Rx.channelMask==4 && size(app.Rx.iq,1)==65520);
z=app.Rx.iq(:,3);
assert(all(isfinite(z)) && all(isnan(app.Rx.iq(:,[1 2 4:8])),'all'));
zeroFraction=mean(z==0);
assert(zeroFraction<0.05,'ADC record contains excessive zero data: %.3f%%',100*zeroFraction);
n=numel(z); window=0.5-0.5*cos(2*pi*(0:n-1)'/(n-1));
spectrum=abs(fft((z-mean(z)).*window));
[~,bin]=max(spectrum(2:floor(n/2))); peakHz=bin*app.Rx.Fs/n;
assert(abs(peakHz-100e6)<1.5e6,'ADC CH2 did not recover the test-tone band: %.6f MHz',peakHz/1e6);
app.saveCapture(strrep(csv,'.csv','.mat'));
app.UI.span.Value='1024'; app.render; drawnow;
exportapp(app.Figure,strrep(csv,'.csv','.png'));
fprintf('PASS: actual ADC CH2 imported/plotted/saved in MATLAB: N=%d, Fs=%.0f, FFT peak=%.6f MHz, zero fraction=%.6f%%.\n', ...
    n,app.Rx.Fs,peakHz/1e6,100*zeroFraction);
end
