function hnm = rir_from_parametric(fs, N, delay, amp, doa, isComplexSH)

%% defaults
if nargin<6
    isComplexSH = true;
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

end

