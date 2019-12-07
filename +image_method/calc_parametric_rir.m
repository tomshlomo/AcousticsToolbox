function reflections = calc_parametric_rir(roomDim, sourcePos, arrayPos, ...
    R, varargin)
% calc_parametric_rir returns a table containing a parametric
% representation of shoe box room impulse responde, using the image method.
% The source is assumed to be omni-directional.
%
% Inputs:
%   roomDim         Dimensions of the room, meters. [Lx, Ly, Lz].
%   sourcePos       The location of the source inside the room, meters.
%                   [x, y, z].
%   arraPos         The location of the array inside the room, meters.
%                   [x, y, z].
%   R               Walls reflection coeffecients. Either a scalar, or a
%                   6-vector so that each wall has a different coeffecient.
%                   [x=0, y=0, z=0, x=Lx, y=Ly, z=Lz]
% Name-Value pairs:
%   Tmax            The maximal delay.
%                   Default value is according to sabine T60.
%   EnergyThresh    If positive, than the late part of the response will be
%                   removed. The energy of that part is approximately
%                   EnergyThresh time the total energy.
%                   Default if 0 (so nothing is removed).
%   MaxWaves        The maximum number of waves in the response. If the
%                   number of waves is larger, than late reflections will 
%                   be removed.
%                   Default is inf.
%   c               Speed of sound, in m/sec.
%                   Default is the output of the function soundspeed().
%   ZeroFirstDelay  Boolean. If true, the delays are shifted so that the
%                   first is 0.
%                   Default is false.
%
%   Output:
%       reflections A table, where each row represents a single point
%       source (reflection). The columns are:
%           delay           Delay, sec
%           amp             Amplitude (including radial decay)
%           relativePos     Relative position of point sorce, relative to the
%                           array, meters [x, y, z]
%           r               Distance of the point source from the array,
%                           meters.
%           omega           The direction of the point source, relative to
%                           the array, radians [theta, phi].
%           index           A 3-vector describingthe "path" of the reflection.
%                           For example, [0 0 0] is the direct sound.
%                           [1 0 0] is the first reflection from x=Lx.
%                           [-1 0 0] is the first reflection from x=0.
%                           [2 0 0] is the relfection of [-1 0 0] from
%                           x=Lx.

%% input validation and defaults
zeroFirstDelay = false;
maxWaves = inf;
energyThresh = 0;
maxReflectionOrder = [];
Tmax = [];
c = soundspeed();
for i=1:2:length(varargin)
    name = varargin{i};
    val = varargin{i+1};
    switch lower(name)
        case 'tmax'
            Tmax = val;
        case {'energythresh','energythreshold'}
            energyThresh = val;
        case 'zerofirstdelay'
            zeroFirstDelay = val;
        case 'maxwaves'
            maxWaves = val;
        case 'c'
            c = val;
        otherwise
            error('unknown parameter %s', name);
    end
end
assert(isvector(sourcePos) && length(sourcePos)==3, 'sourcePos must be a 3-vector');
sourcePos = sourcePos(:)';
assert(isvector(arrayPos)  && length(arrayPos) ==3, 'arrayPos must be a 3-vector');
arrayPos = arrayPos(:)';
if isempty(Tmax)
    Tmax = image_method.sabineT60(roomDim, R, c);
end
if isempty(maxReflectionOrder)
    maxReflectionOrder = ceil(Tmax*c./roomDim);
end

%%
reflections = table();
[reflections.relativePos, reflections.amp, reflections.index] = image_method.calc_reflections_info( roomDim, sourcePos, R, maxReflectionOrder );
reflections.relativePos = reflections.relativePos - arrayPos;
reflections.r = sqrt( sum( reflections.relativePos.^2, 2 ) );
reflections.delay = reflections.r/c;

%% filter by Tmax and calculate amplitude
I = reflections.delay<=Tmax;
reflections = reflections(I,:);
reflections.amp = reflections.amp./reflections.r;

%% sort by delay
reflections = sortrows(reflections, 'delay');

%% filter by energyThresh
if energyThresh>0
    accumulated_energy = cumsum(abssq(reflections.amp));
    k = find( accumulated_energy > (1-energyThresh)*accumulated_energy(end), 1 );
    if ~isempty(k)
        reflections(k+1:end,:) = [];
    end
end

%% filter by max waves
reflections(maxWaves+1:end,:) = [];

%% zero first delay
if zeroFirstDelay
    reflections.delay = reflections.delay - reflections.delay(1);
end

%% calculate omega
[reflections.omega(:,1), reflections.omega(:,2)] = c2s(reflections.relativePos); 

end

