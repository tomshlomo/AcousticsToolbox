function h = scatter(th, ph, s, c, marker, varargin)

if nargin<3
    s = 500;
end
if nargin<5
    marker = '.';
end

[x,y] = hammer.project(th, ph);
h = scatter(x, y, s, c, marker, varargin{:});
hammer.axes(h.Parent);

end

