function tx = awg_export_real(samples, outDir, channelMask)
%AWG_EXPORT_REAL Export 9 GS/s signed real samples for 256-bit No-DUC playback.
% A 512-bit playback RAM word holds 32 samples. Each HEX line packs two
% consecutive signed 16-bit samples into one 32-bit JTAG word.
if nargin<3, channelMask=255; end
validateattributes(samples,{'numeric'},{'2d','real','finite','nonempty'});
assert(size(samples,2)>=1 && size(samples,2)<=8, 'Expected one to eight real channels.');
assert(size(samples,1)>=32 && size(samples,1)<=65536 && mod(size(samples,1),32)==0, ...
    'Expected 32..65536 real samples/channel, divisible by 32 (512-bit RAM words).');
validateattributes(channelMask,{'numeric'},{'scalar','integer','>=',1,'<=',255});
assert(max(abs(double(samples(:))))<=1, 'Normalize real samples to [-1,1].');
if ~isfolder(outDir), mkdir(outDir); end
codes=int16(round(max(-1,min(1,double(samples)))*32767));
codes(:,end+1:8)=0;
for ch=1:8
    if ~bitget(uint8(channelMask),ch), codes(:,ch)=0; end
    pair=bitor(uint32(typecast(codes(1:2:end,ch),'uint16')), ...
        bitshift(uint32(typecast(codes(2:2:end,ch),'uint16')),16));
    fid=fopen(fullfile(outDir,sprintf('ch%d.hex',ch-1)),'wt');
    assert(fid>=0,'Cannot create channel file.');
    cleanup=onCleanup(@() fclose(fid));
    fprintf(fid,'%08X\n',pair);
    clear cleanup
end
tx=struct('samples',codes,'Fs',9e9,'channelMask',double(channelMask), ...
    'sampleFormat','real-int16','ducEnabled',false);
fid=fopen(fullfile(outDir,'waveform.meta'),'wt');
assert(fid>=0,'Cannot create metadata file.');
cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'samples %d\nfs_hz %d\nnco_hz 0\nchannel_mask %d\nsample_format 1\n', ...
    size(codes,1),9000000000,channelMask);
clear cleanup
save(fullfile(outDir,'waveform.mat'),'-struct','tx','-v7.3');
fprintf('Exported %d real samples/channel, mask=0x%02X to %s\n',size(codes,1),channelMask,outDir);
end
