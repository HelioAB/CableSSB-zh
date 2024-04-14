function [fig,ax] = plot(obj,options)
    arguments
        obj
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
        options.LoadScale {mustBeNumeric} = 1e-6
    end
    fig = options.Figure;
    ax = options.Axis;
    obj.plotStructure(fig,ax);
    axis equal
    obj.plotCoupling(fig,ax);
    obj.plotContraint(fig,ax);
    obj.plotLoad(fig,ax,options.LoadScale);
end