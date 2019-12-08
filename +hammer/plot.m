function h = plot(th, ph, varargin)

[x,y] = hammer.project(th, ph);
h = plot(x, y, varargin{:});
hammer.axes(h.Parent);

end