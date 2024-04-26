function [fig,ax] = plot(obj,S,C,options)
    arguments
        % 均为MATLAB中默认的参数值
        obj
        S = 2
        C = 'k'
        options.LineWidth = 0.5
        options.Filled (1,1) {mustBeNumericOrLogical} = false
        options.MarkerType = 'o'
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
    end
    % 其他参数通过访问对象point_handle的属性值修改
    figure(options.Figure)
    s = scatter3(options.Axis,[obj.X],[obj.Y],[obj.Z]);
    s.LineWidth = options.LineWidth;
    s.Marker = options.MarkerType;
    s.SizeData = S;
    if options.Filled
        s.MarkerEdgeColor = "none";
        s.MarkerFaceColor = C;
    else
        s.MarkerEdgeColor = C;
        s.MarkerFaceColor = "none";
    end
    view(3);
    fig = options.Figure;
    ax = options.Axis;
end