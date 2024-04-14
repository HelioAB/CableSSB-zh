function point_handle = plot(obj,S,C,options)
    arguments
        % 均为MATLAB中默认的参数值
        obj
        S = 5
        C = 'k'
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
    end
    % 其他参数通过访问对象point_handle的属性值修改
    figure(options.Figure)
    point_handle = scatter3(options.Axis,[obj.X],[obj.Y],[obj.Z],S,C);
    view(3);
end