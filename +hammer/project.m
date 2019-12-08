function [x, y] = project(th, ph)
% https://en.wikipedia.org/wiki/Hammer_projection

if nargin==1 && size(th,2) == 2
    ph = th(:,2);
    th = th(:,1);
end
ph = mod2(ph, 2*pi);

%% get lambda and phi
lambda2 = ph/2;
phi = pi/2-th;

cos_phi = cos(phi);
denom = sqrt(1 + cos_phi .* cos(lambda2));
x = sqrt(8) .* cos_phi .* sin(lambda2) ./ denom;
y = sqrt(2) .* sin(phi) ./ denom;

end

