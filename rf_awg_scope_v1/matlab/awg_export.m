function tx = awg_export(iq, outDir, channelMask)
%AWG_EXPORT Export normalized N-by-8 complex MATLAB samples for awg::load.
% Column 1 is physical CH0. One HEX word is Q[15:0],I[15:0].
if nargin < 3, channelMask = 255; end
validateattributes(iq, {'double','single'}, {'2d','finite','nonempty'});
assert(size(iq,2)==8 && size(iq,1)>=4 && size(iq,1)<=32768 && mod(size(iq,1),4)==0, ...
    'Expected N-by-8 iq, N=4..32768 and divisible by four.');
validateattributes(channelMask, {'numeric'}, {'scalar','integer','>=',1,'<=',255});
assert(all(abs(real(iq(:)))<=1 & abs(imag(iq(:)))<=1), 'Normalize I and Q to [-1,1].');
I = int16(round(double(real(iq))*32767));
Q = int16(round(double(imag(iq))*32767));
if ~isfolder(outDir), mkdir(outDir); end
for ch = 1:8
    if ~bitget(uint8(channelMask),ch), I(:,ch)=0; Q(:,ch)=0; end
    words = bitor(bitshift(uint32(typecast(Q(:,ch),'uint16')),16), ...
        uint32(typecast(I(:,ch),'uint16')));
    fid = fopen(fullfile(outDir,sprintf('ch%d.hex',ch-1)),'wt');
    assert(fid>=0,'Cannot open waveform file.');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid,'%08X\n',words);
    clear cleanup
end
tx = struct('iq',complex(double(I),double(Q)), 'I',I,'Q',Q, ...
    'Fs',625000000,'ncoHz',1500000000,'channelMask',double(channelMask));
fid = fopen(fullfile(outDir,'waveform.meta'),'wt');
assert(fid>=0,'Cannot open metadata.');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'samples %d\nfs_hz %d\nnco_hz %d\nchannel_mask %d\n', ...
    size(iq,1),tx.Fs,tx.ncoHz,channelMask);
clear cleanup
save(fullfile(outDir,'waveform.mat'),'-struct','tx','-v7');
fprintf('Exported %d samples/channel, mask=0x%02X to %s\n',size(iq,1),channelMask,outDir);
end
