function rx = awg_import_ila(csvPath, matPath, channelMask)
%AWG_IMPORT_ILA Recover complete ADC I/Q without converting 512-bit to double.
% rx.iq is N-by-8 complex ADC codes; columns 1..8 correspond to CH0..CH7.
% Uses base MATLAB only. CSV and matching JSON come from awg::capture.
if nargin<2, matPath=''; end
[folder,name] = fileparts(csvPath);
meta = jsondecode(fileread(fullfile(folder,[name '.json'])));
if nargin<3, channelMask=meta.channel_mask; end
validateattributes(channelMask,{'numeric'},{'scalar','integer','>=',1,'<=',255});
validateattributes(meta.fs_hz,{'numeric'},{'scalar','finite','positive'});
validateattributes(meta.nco_hz,{'numeric'},{'scalar','finite'});
fid = fopen(csvPath,'rt'); assert(fid>=0,'Cannot open capture CSV.');
cleanup = onCleanup(@() fclose(fid));
header={};
while ~feof(fid)
    line=fgetl(fid);
    if contains(line,'scope_adc_i'), header=csvFields(line); break; end
end
assert(~isempty(header),'Missing scope_adc_i: use matching V1 bit/LTX.');
names={'scope_adc_i','scope_adc_q','scope_metadata','scope_beat_counter'};
widths=[512 512 64 32]; columns=zeros(1,4);
for k=1:4
    matches=find(contains(header,names{k}));
    if numel(matches)>1
        matches=matches(contains(header(matches),sprintf('[%d:0]',widths(k)-1)));
    end
    assert(numel(matches)==1,'Missing or ambiguous probe: %s',names{k});
    columns(k)=matches;
end
radix=csvFields(fgetl(fid));
hasRadixLabel=~isempty(regexp(radix{1},'^Radix(?:\s*-\s*.*)?$','ignorecase','once'));
assert(numel(radix)==numel(header) && hasRadixLabel,'CSV must retain Radix row.');
captureBeats=8192;
if isfield(meta,'capture_beats'), captureBeats=double(meta.capture_beats); end
assert(captureBeats>=2 && captureBeats<=8192, ...
    'Capture depth must be 2..8192 beats for this ILA configuration.');
I=zeros(captureBeats*4,8,'int16'); Q=I;
status=zeros(captureBeats,1,'uint64'); counter=zeros(captureBeats,1,'uint32');
beat=0;
while ~feof(fid)
    line=fgetl(fid); if isempty(strtrim(line)), continue; end
    row=csvFields(line);
    assert(numel(row)==numel(header),'Wrong CSV column count at beat %d.',beat);
    beat=beat+1; assert(beat<=captureBeats,'Capture exceeds configured ILA depth.');
    wi=parseWords(row{columns(1)},radix{columns(1)},32);
    wq=parseWords(row{columns(2)},radix{columns(2)},32);
    wm=parseWords(row{columns(3)},radix{columns(3)},4);
    ws=parseWords(row{columns(4)},radix{columns(4)},2);
    I(4*beat-3:4*beat,:)=reshape(typecast(wi,'int16'),4,8);
    Q(4*beat-3:4*beat,:)=reshape(typecast(wq,'int16'),4,8);
    for k=1:4, status(beat)=bitor(status(beat),bitshift(uint64(wm(k)),16*(k-1))); end
    counter(beat)=bitor(uint32(ws(1)),bitshift(uint32(ws(2)),16));
end
assert(beat>=2,'Capture needs at least two beats.');
if isfield(meta,'capture_beats')
    assert(beat==meta.capture_beats,'Partial ILA capture: expected %d beats, got %d.',meta.capture_beats,beat);
end
I=I(1:4*beat,:); Q=Q(1:4*beat,:); status=status(1:beat); counter=counter(1:beat);
assert(all(mod(diff(double(counter)),2^32)==1),'Non-contiguous capture; FFT refused.');
validMask=uint64(0);
for ch=0:7
    if bitget(uint8(channelMask),ch+1), validMask=bitor(validMask,bitshift(uint64(3),2*ch)); end
end
assert(all(bitand(status,validMask)==validMask),'ADC I/Q valid dropped in a selected channel.');
assert(all(bitget(status,43)==1),'Capture precedes PS initialization.');
assert(all(bitand(bitshift(status,-32),uint64(255))==0),'DAC handshake fault in capture.');
meta.channel_mask=double(channelMask);
rx=struct('iq',complex(double(I),double(Q)), 'I',I,'Q',Q, ...
    'Fs',double(meta.fs_hz),'ncoHz',double(meta.nco_hz), ...
    'channelMask',double(channelMask),'beatCounter',counter,'status',status,'metadata',meta);
rx.iqNormalized=rx.iq/32768;
rx.t=(0:size(I,1)-1)'/rx.Fs;
if ~isempty(matPath), save(matPath,'-struct','rx','-v7'); end
fprintf('Recovered %d consecutive beats, %d complex samples/channel.\n',beat,size(I,1));
end

function fields=csvFields(line)
assert(ischar(line),'Unexpected end of CSV.');
fields=regexp(line,',(?=(?:[^"]*"[^"]*")*[^"]*$)','split');
fields=cellfun(@(x) strrep(regexprep(strtrim(x),'^"|"$',''),'""','"'),fields,'UniformOutput',false);
end

function words=parseWords(value,radix,nWords)
value=strrep(strtrim(value),'_',''); radix=upper(radix);
if contains(radix,'HEX') && startsWith(lower(value),'0x'), value=value(3:end); end
if contains(radix,'BIN') && startsWith(lower(value),'0b'), value=value(3:end); end
assert(~isempty(value) && isempty(regexpi(value,'[xz]')), 'Unknown/invalid ILA word.');
words=zeros(1,nWords,'uint16');
if contains(radix,'HEX') || contains(radix,'BIN')
    binary=contains(radix,'BIN'); group=4; pattern='^[0-9a-fA-F]+$';
    if binary, group=16; pattern='^[01]+$'; end
    assert(~isempty(regexp(value,pattern,'once')),'Invalid HEX/BIN word.');
    value=regexprep(value,'^0+','');
    assert(numel(value)<=nWords*group,'ILA value exceeds probe width.');
    for k=1:ceil(numel(value)/group)
        last=numel(value)-(k-1)*group; chunk=value(max(1,last-group+1):last);
        if binary, words(k)=uint16(bin2dec(chunk)); else, words(k)=uint16(hex2dec(chunk)); end
    end
elseif contains(radix,'DEC') || contains(radix,'SIGNED')
    assert(~isempty(regexp(value,'^[0-9]+$','once')),'Export signed wide probes as HEX.');
    % Base-65536 arithmetic keeps even a decimal 512-bit word exact.
    for digit=value
        carry=double(digit)-double('0');
        for k=1:nWords
            v=double(words(k))*10+carry; words(k)=uint16(mod(v,65536)); carry=floor(v/65536);
        end
        assert(carry==0,'ILA value exceeds probe width.');
    end
else
    error('Unsupported radix: %s',radix);
end
end
