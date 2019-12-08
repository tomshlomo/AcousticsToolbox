function ax = axes(ax)

if nargin<1
    ax = axes();
end

hPatch = findobj(ax.Children, 'tag', 'ellipse_patch');
hGrid = [findobj(ax.Children, 'tag', 'ph_grid'); findobj(ax.Children, 'tag', 'th_grid')];
hRest = setdiff(ax.Children, [hPatch; hGrid]);
if isempty(hPatch)
    zmin = -eps();
else
    zmin = hPatch(1).ZData(1);
end
if isempty(hGrid)
    zmax = eps();
else
    zmax = hGrid(1).ZData(1);
end
for i=1:length(hRest)
    if ~isempty(hRest(i).ZData)
        zmin = min(zmin, min(hRest(i).ZData, [], 'all', 'omitnan'));
        zmax = max(zmax, max(hRest(i).ZData, [], 'all', 'omitnan'));
    end
end

if ax.Tag=="hammer_ax"
    hPatch.ZData(:) = zmin;
    for i=1:length(hGrid)
        hGrid(i).ZData(:) = zmax;
    end
else
    ax.Tag = "hammer_ax";
    t = linspace(0, 2*pi, 100);
    x = sqrt(8)*cos(t);
    y = sqrt(2)*sin(t);
    patch(x, y, repmat(zmin, size(x)), [1 1 1], 'Parent', ax, 'tag', 'ellipse_patch')
    hammer.grid();
    dcm = datacursormode(ax.Parent);
    dcm.UpdateFcn = @(~,evnt) dcm_callback(evnt);
    dcm.Interpreter = 'latex';
    hold(ax, 'on');
end
view(ax, 2);

    function txt = dcm_callback(evnt)
        [th, ph] = hammer.inv( evnt.Position(1), evnt.Position(2) );
        txt = {sprintf('$\\theta$: $%.1f ^\\circ$', th*180/pi);...
            sprintf('$\\phi$: $%.1f ^\\circ$', ph*180/pi)};
    end
end