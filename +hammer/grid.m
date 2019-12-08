function [h_th, h_ph] = grid(thRes_deg, phRes_deg, ax, varargin)

if nargin<3
    ax = gca;
end
if nargin<1
    thRes_deg = 30;
end
if nargin<2
    phRes_deg = 60;
end
z = eps();
for i=1:length(ax.Children)
    if ~isempty(ax.Children(i).ZData)
        z = max(z, max(ax.Children(i).ZData(:)));
    end
end
th_deg = ( thRes_deg : thRes_deg : 180 );
th_deg(th_deg==180) = [];
th_rad = th_deg*pi/180;
ph_for_th = (-175 : 5 : 175)'*pi/180;
[x, y] = hammer.project(th_rad, ph_for_th);
ih = ishold(ax);
hold(ax, 'on');
h_th = plot3( x, y, repmat(z, size(x)), '--', 'LineWidth', 0.5, 'Parent', ax, 'Color', [0.5 0.5 0.5], ...
    'tag', 'th_grid', varargin{:} );

ph_deg = ( (-180+phRes_deg) : phRes_deg : 180 );
ph_deg(ph_deg==180) = [];
ph_rad = ph_deg*pi/180;
th_for_ph = (0 : 5 : 180)'*pi/180;
[x, y] = hammer(th_for_ph, ph_rad);
h_ph = plot3( x, y, repmat(z, size(x)), '--', 'LineWidth', 0.5, 'Parent', ax, 'Color', [0.5 0.5 0.5], ...
    'tag', 'ph_grid', varargin{:} );

axis(ax, 'off');
if ~ih
    hold(ax, 'off');
end

view(ax, [0 90]);
axis(ax, 'tight');
axis(ax, 'equal');
end

