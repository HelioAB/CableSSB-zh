function [fig,ax] = plot(obj)
    fig = figure;
    ax = axes;
    hold(ax,'on')
    obj.Element.plot('Figure',fig,'Axis',ax);
    obj.Node.plot('Figure',fig,'Axis',ax);
    axis equal
end