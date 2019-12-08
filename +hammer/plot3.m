function h = plot3(th, ph, z, varargin)

[x,y] = hammer.project(th, ph);
h = plot3(x, y, z, varargin{:});
hammer.axes(h.Parent);

end