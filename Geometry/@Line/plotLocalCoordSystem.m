function plotLocalCoordSystem(obj,OriginCoord,options)
    arguments
        obj
        OriginCoord (:,3) {mustBeNumeric} % 坐标原点
        options.Scale {mustBePositive} = 1.0 % 缩放倍数
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
    end
    sz = size(OriginCoord);

    start_X = OriginCoord(:,1)';
    start_Y = OriginCoord(:,2)';
    start_Z = OriginCoord(:,3)';

    [dir_x,dir_y,dir_z] = obj.getLocalCoordSystem;

    delta_X_x = options.Scale*dir_x(:,1)';
    delta_Y_x = options.Scale*dir_x(:,2)';
    delta_Z_x = options.Scale*dir_x(:,3)';

    delta_X_y = options.Scale*dir_y(:,1)';
    delta_Y_y = options.Scale*dir_y(:,2)';
    delta_Z_y = options.Scale*dir_y(:,3)';

    delta_X_z = options.Scale*dir_z(:,1)';
    delta_Y_z = options.Scale*dir_z(:,2)';
    delta_Z_z = options.Scale*dir_z(:,3)';
    
    view(3)
    figure(options.Figure)
    hold(options.Axis,'on')
    axis equal
    % x轴
    arrow = quiver3(options.Axis,start_X,start_Y,start_Z,delta_X_x,delta_Y_x,delta_Z_x,'off');
    arrow.Color = Structure.X_axis_color;
    arrow.MaxHeadSize  = 0.1;
    % y轴
    arrow = quiver3(options.Axis,start_X,start_Y,start_Z,delta_X_y,delta_Y_y,delta_Z_y,'off');
    arrow.Color = Structure.Y_axis_color;
    arrow.MaxHeadSize  = 0.1;
    % z轴
    arrow = quiver3(options.Axis,start_X,start_Y,start_Z,delta_X_z,delta_Y_z,delta_Z_z,'off');
    arrow.Color = Structure.Z_axis_color;
    arrow.MaxHeadSize  = 0.1;
end