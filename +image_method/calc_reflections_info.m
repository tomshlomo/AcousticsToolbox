function [reflectionPos, amp, reflectionIndex] = calc_reflections_info( roomDim, sourcePos, R, maxReflectionOrder )

%% input validation
if isscalar(R)
    R = repmat(R, 6, 1);
end
assert(isvector(R) && length(R)==6, 'R must be a scalar or a vector of length 6');
R = R(:)'; % make row vector

if isscalar(maxReflectionOrder)
    maxReflectionOrder = repmat(maxReflectionOrder, 3, 1);
end
assert(isvector(maxReflectionOrder) && length(maxReflectionOrder)==3, 'maxReflectionOrder must be a scalar or a vector of length 3');

%% 
[i1, i2, i3] = ndgrid(-maxReflectionOrder(1):maxReflectionOrder(1),...
                      -maxReflectionOrder(2):maxReflectionOrder(2),...
                      -maxReflectionOrder(3):maxReflectionOrder(3));
reflectionIndex = [i1(:) i2(:) i3(:)];
clear i1 i2 i3

cornerIndex = floor( (reflectionIndex+1)/2 );
cornerPos = cornerIndex .* (2*roomDim);
clear cornerIndex

reflectionPos = (-1).^(reflectionIndex).*sourcePos + cornerPos;
clear cornerPos

power1 = zeros(size(reflectionIndex));
I = reflectionIndex>0;
power1(I) = ceil(abs(reflectionIndex(I))/2);
power1(~I) = floor(abs(reflectionIndex(~I))/2);
power2 = abs(reflectionIndex)-power1;

if nargout>=2
    amp = prod( [R(1:3).^power1 R(4:6).^power2], 2);
end

end