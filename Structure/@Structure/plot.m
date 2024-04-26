function [fig,ax] = plot(obj,options)
    arguments
        obj (1,1)
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
    end
    figure(options.Figure) % 将options.Figure设置为当前图窗
    hold(options.Axis,'on')
    obj.Point.plot('Figure',options.Figure,'Axis',options.Axis);
    obj.Line.plot('Figure',options.Figure,'Axis',options.Axis);

    fig = options.Figure;
    ax = options.Axis;
end