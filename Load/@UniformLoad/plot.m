function arrow_handle = plot(obj,options)
    arguments
        obj
        options.Color = 'm'
        options.Scale {mustBeNumeric} = 1 % 通过plot中的可选参数Scale控制箭头的长短，而不是quiver3函数自带的Scale属性
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
        options.LineWidth = 1
        options.Offset = [0,0,0]
    end
    application = obj.AppliedPosition;
    apply_ipoint = [application.IPoint];
    apply_jpoint = [application.JPoint];
    apply_ijpoint = [apply_ipoint,apply_jpoint];
    
    len = length(application);
    delta_X_i = zeros(1,len);
    delta_Y_i = zeros(1,len);
    delta_Z_i = zeros(1,len);
    delta_X_j = zeros(1,len);
    delta_Y_j = zeros(1,len);
    delta_Z_j = zeros(1,len);

    scale = options.Scale;

    switch obj.Direction
        case 'X'
            for i=1:len
                delta_X_i(i) = scale*obj.Value{i};
                delta_X_j(i) = scale*obj.Value{i};
            end
        case 'Y'
            for i=1:len
                delta_Y_i(i) = scale*obj.Value{i};
                delta_Y_j(i) = scale*obj.Value{i};
            end
        case 'Z'
            for i=1:len
                delta_Z_i(i) = scale*obj.Value{i};
                delta_Z_j(i) = scale*obj.Value{i};
            end
        case 'None'
    end
    figure(options.Figure)
    hold(options.Axis,'on')
    arrow_handle = Load.getArrow(apply_ijpoint,[delta_X_i,delta_X_j],[delta_Y_i,delta_Y_j],[delta_Z_i,delta_Z_j],...
                                 options.Color,options.Figure,options.Axis,...
                                 'LineWidth',options.LineWidth,...
                                 'Offset',options.Offset);

    start_X_i = [apply_ipoint.X]-delta_X_i+options.Offset(1);
    start_X_j = [apply_jpoint.X]-delta_X_j+options.Offset(1);
    start_Y_i = [apply_ipoint.Y]-delta_Y_i+options.Offset(2);
    start_Y_j = [apply_jpoint.Y]-delta_Y_j+options.Offset(2);
    start_Z_i = [apply_ipoint.Z]-delta_Z_i+options.Offset(3);
    start_Z_j = [apply_jpoint.Z]-delta_Z_j+options.Offset(3);

    delta_X_ij = start_X_j-start_X_i;
    delta_Y_ij = start_Y_j-start_Y_i;
    delta_Z_ij = start_Z_j-start_Z_i;

    arrowline_handle = quiver3(options.Axis,start_X_i,start_Y_i,start_Z_i,delta_X_ij,delta_Y_ij,delta_Z_ij,'off');
    arrowline_handle.ShowArrowHead = 'off';
    arrowline_handle.Color = options.Color;
    arrowline_handle.MaxHeadSize  = 0.1;
    arrowline_handle.LineWidth = options.LineWidth;
end
