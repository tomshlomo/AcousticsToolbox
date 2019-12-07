function [hnm, parametric] = calc_rir(fs, N, roomDim, sourcePos, arrayPos, R, isComplexSH, varargin)
% for details about name-value argument see
% image_method.calc_parametric_rir.m

if nargin<7
    isComplexSH = true;
end

%% calc paramteric info
parametric = image_method.calc_parametric_rir(roomDim, sourcePos, arrayPos, ...
    R, varargin{:});

%% convert to rir signal
hnm = rir_from_parametric(fs, N, parametric.delay, parametric.amp, parametric.omega, isComplexSH);

end

