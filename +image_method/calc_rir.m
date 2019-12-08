function [hnm, parametric] = calc_rir(fs, N, roomDim, sourcePos, arrayPos, R, varargin)
% for details about name-value argument see
% image_method.calc_parametric_rir.m and rir_from_parametric.m.

% split varargin
k = false(length(varargin),1);
for i=1:2:length(varargin)
    name = varargin{i};
    switch lower(name)
        case {'complexsh','iscomplexsh', 'bpf'}
            k([i i+1]) = true;
    end
end

%% calc paramteric info
parametric = image_method.calc_parametric_rir(roomDim, sourcePos, arrayPos,R, varargin{~k});

%% convert to rir signal
hnm = rir_from_parametric(fs, N, parametric.delay, parametric.amp, parametric.omega, varargin{k});

end