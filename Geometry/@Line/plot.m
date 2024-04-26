function [fig,ax] = plot(obj,options)
    arguments
        obj
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
        options.Color = 'k'
    end
    IPoints = [obj.IPoint];
    JPoints = [obj.JPoint];
    X = [[IPoints.X];[JPoints.X]]; % plot3的XYZ的矩阵size: (2,线条条数) ,其中2表示I点和J点
    Y = [[IPoints.Y];[JPoints.Y]];
    Z = [[IPoints.Z];[JPoints.Z]];
    figure(options.Figure) % 将options.Figure设置为当前图窗
    plot3(options.Axis,X,Y,Z,'Color',options.Color);
    view(3);

    fig = options.Figure;
    ax = options.Axis;
end