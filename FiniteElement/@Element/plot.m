function [fig,ax,X,Y,Z] = plot(obj,options)
    arguments
        obj
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
        options.Color = 'k'
    end
    INodes = [obj.INode];
    JNodes = [obj.JNode];
    X = [[INodes.X];[JNodes.X]]; % plot3的XYZ的矩阵size: (2,线条条数) ,其中2表示I点和J点
    Y = [[INodes.Y];[JNodes.Y]];
    Z = [[INodes.Z];[JNodes.Z]];
    figure(options.Figure) % 将options.Figure设置为当前图窗
    line_handle = plot3(options.Axis,X,Y,Z,'Color',options.Color);
    view(3);

    fig = options.Figure;
    ax = options.Axis;
end