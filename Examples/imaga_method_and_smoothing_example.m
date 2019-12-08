
%% load clean speech file
rng('default');
[x, fs] = clean_speeach("male",2.4); % 2.4 to stop after "yorkshire"
soundsc(x,fs);

%% generate RIR and convolve with speech
N = 3; % SH order
roomDim = [4 6 3];
sourcePos = [2 1 1.7]+0.1*randn(1,3);
arrayPos = [2 5 1]+0.1*randn(1,3);
R = 0.8; % walls refelection coeff
[hnm, reflectionsInfo] = image_method.calc_rir(fs, N, roomDim, sourcePos, arrayPos, R, 'bpf', true);
figure; plot((0:size(hnm,1)-1)/fs, real(hnm(:,1))); % plot the RIR of a_00
xlabel('Time [sec]');
anm = fftfilt(hnm, [x; zeros(size(hnm,1)-1,1)], 2^15); % 2^15 seems to be the fastest on my mac
soundsc(real(anm(:,1)), fs);

%% calculate STFT (you should download and add to path the stft function from: https://github.com/tomshlomo/stft)
windowLength_sec = 50e-3;
window = hann( round(windowLength_sec*fs) );
hop = floor(length(window)/4);
[anm_stft, fVec, tVec] = stft(anm, window, hop, [], fs);
anm_stft = anm_stft(1:size(anm_stft,1)/2+1,:,:); % discard negative frequencies
fVec = fVec(1:size(anm_stft,1));

% plot
figure;
hIm = imagesc(tVec, fVec, 10*log10(abssq(anm_stft(:,:,1))));
hIm.Parent.YDir = 'normal';
xlabel('Time [sec]'); ylabel('Frequency [Hz]');
axis tight;
ylim([0 2000]);
hIm.Parent.CLim = max(hIm.CData, [], 'all') + [-60 0]; % fix dynamic range of display

%% Perform smoothing and DPD test
SCM = smoothing_stft(anm_stft, 'TimeSmoothingWidth', 2, 'FreqSmoothingWidth', 10);
[U, lambda] = eignd(SCM, [3 4]);
dpd = lambda(:,:,1)./sum(lambda, 3); % when dpd is close to 1, it means that SCM is nearly rank 1.
dpdThresh = 0.95;
dpdTest = dpd >= dpdThresh;
hold on;
image(tVec, fVec, zeros([size(dpd) 3]), 'AlphaData', double(dpdTest));

%% Estimate DOA using music
% get only bins that passed DPD test
Uf = permute(U(:,:,:,1).*lambda(:,:,1), [3 1 2]);
Uf = reshape(Uf, size(Uf,1), []);
Uf = Uf(:, dpdTest(:));

% get grid of directions
omega = sampling_schemes.fibonacci(1000);

% calculate the IDSFT of each (unnormalized) eigen-vector
Y = shmat(N, omega);
x = Y*Uf;

% for each eigen-vector, find the direction with most energy
[m,k] = max(abssq(x), [], 1);

% build a weighted histograms of directions. estimated DOA is it's peak
hist = accumarray(k', m', [size(omega,1) 1]);
figure;
hammer.scatter(omega(:,1), omega(:,2), 1000, hist);
doa = reflectionsInfo.omega(1,:);
hammer.plot(doa(1), doa(2), 'rx', 'MarkerSize', 20, 'LineWidth', 3);
[~,k] = max(hist);
doaEsitmated = omega(k,:);
estimatedError = acosd( s2c(doaEsitmated)*s2c(doa)' );
