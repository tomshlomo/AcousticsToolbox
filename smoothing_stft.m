function R = smoothing_stft(P, varargin)

%% defaults and input parsing
Q = size(P,3);
T = size(P,2);
F = size(P,1);
focusingMatrices = [];
timeSmoothingType = 'none';
freqSmoothingType = 'none';
for i=1:2:length(varargin)
    name = varargin{i};
    val = varargin{i+1};
    switch lower(name)
        case {'focusing','focusingmatrices','focusingmatrix','focusingmatrixes'}
            focusingMatrices = val;
        case {'timesmoothingwidth','timewidth'}
            k_time = val;
            timeSmoothingType = 'movmean';
        case {'freqsmoothingwidth','frequencysmoothingwidth','freqwidth','frequencywidth'}
            k_freq = val;
        case {'alpha'}
            alpha = val;
            timeSmoothingType = 'iir';
        otherwise
            error('unknown option: %s', name);
    end
end

%% apply focusing
if ~isempty(focusingMatrices)
    assert(size(focusingMatrices,3)==F, 'size(focusingMatrices,3) (number of focusing matrices) must be the same as size(P,1) (number of frequencies)');
    assert(size(focusingMatrices,2)==Q, 'size(focusingMatrices,2) must be the same as size(P,3) (number of channels)');
    Qold = Q;
    Q = size(focusingMatrices,2);
    % add layers to P (if needed)
    if size(focusingMatrices,1)>Q
        P = cat(3, P, zeros(F, T, Q-Qold));
    end
    % apply focusing matrices for each band
    for f=1:F
        P(f, :, 1:Q) = ipermute( focusingMatrices(:,:,f) * permute( P(f,:,:), [3 2 1] ), [3 2 1] );
    end
    % remove extra layers (if the number of channels was larger before
    % focusing)
    P(:,:,Q+1:end) = [];
end

%% generate flattened, rank-1 estimates
q = (1:Q)';
pairs = [q q; nchoosek(q, 2)];
R1 = P(:, :, pairs(:,1)) .* conj( P(:, :, pairs(:,2)) );
clear P;

%% Time smoothing
switch timeSmoothingType
    case 'movmean'
        R1 = movmean(R1, k_time, 2);
    case 'filter'
        R1 = filter(alpha, [1, alpha-1], R1, [], 2);
    case 'none'
        
    otherwise
        error('unknown timeSmoothingType: %s', timeSmoothingType);
end

%% Frequency smoothing
switch freqSmoothingType
    case 'movmean'
        R1 = movmean(R1, k_freq, 1);
    case 'none'
        
    otherwise
        error('unknown timeSmoothingType: %s', timeSmoothingType);
end

%% unflatten to square matrices
R = zeros(F, T, Q, Q);
for i=1:size(pairs,1)
    R(:,:,pairs(i,1), pairs(i,2)) = R1(:,:,i);
    if i>Q
        R(:,:,pairs(i,2), pairs(i,1)) = conj(R1(:,:,i));
    end
end

end

