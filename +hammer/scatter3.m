function h = scatter3(th, ph, z, s, c, marker, varargin)

if nargin<4
    s = 500;
end
if nargin<6
    marker = '.';
end
[x,y] = hammer.project(th, ph);
h = scatter(x, y, z, s, c, marker, varargin{:});
hammer.axes(h.Parent);
end

