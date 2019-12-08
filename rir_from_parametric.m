function hnm = rir_from_parametric(fs, N, delay, amp, doa, varargin)

%% defaults
isComplexSH = true;
bpfFlag = true;
for i=1:2:length(varargin)
    name = varargin{i};
    val = varargin{i+1};
    switch lower(name)
        case {'complexsh','iscomplexsh'}
            isComplexSH = val;
        case {'bpf'}
            bpfFlag = val;
        otherwise
            error('unknown option: %s', name);
    end
end

%% input validation
assert(isvector(amp), 'amp must ba vector');
amp = amp(:);
assert(isvector(delay), 'delay must be vector');
delay = delay(:);
assert( size(delay,1) == size(amp,1), 'length of delay and amp must be the same' );
assert(size(doa,1)==size(delay,1), 'length of doa and delay must me the same');
assert(size(doa,2)==2, 'doa must have 2 columns (theta, phi)');

%% 
Yh = conj(shmat(N, doa, isComplexSH, true));
Yh_amp = Yh .* amp.';

%% delay to samples
delay = round(delay*fs);

%% accumulate reflections with the same delay
[xx, yy] = ndgrid(delay+1,1:size(Yh_amp, 1));
hnm = accumarray([xx(:) yy(:)], reshape(Yh_amp.', 1, []));

if bpfFlag
    f_low = 20;
    f_high = min(20e3, fs);
    [b,a] = butter(4,[f_low/(fs/2); f_high/(fs/2)]);
    hnm = filter(b,a,hnm,[],1); % BPF to make rir more realistic
end

end

