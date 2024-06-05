function [fig,ax] = plot(obj,options)
    arguments
        obj
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
        options.LoadScale {mustBeNumeric} = 1e-6
        options.LoadLineWidth {mustBeNumeric} = 1
        options.ifPlotPoints = false
        options.ifPlotConstraint = true
        options.ifPlotCoupling = true
        options.ifPlotLoad = true
        options.LoadOffset = [0,0,0]
        options.HidedLoadName = {}
    end
    fig = options.Figure;
    ax = options.Axis;
    obj.plotStructure(fig,ax,'ifPlotPoints',options.ifPlotPoints);
    axis equal

    if options.ifPlotCoupling
        obj.plotCoupling(fig,ax);
    end
    if options.ifPlotConstraint
        obj.plotConstraint(fig,ax);
    end
    if options.ifPlotLoad
        obj.plotLoad(fig,ax,...
                    'Scale',options.LoadScale, ...
                    'LineWidth',options.LoadLineWidth,...
                    'Offset',options.LoadOffset,...
                    'HidedLoadName',options.HidedLoadName);
    end
end