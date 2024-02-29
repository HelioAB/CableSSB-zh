function system_handle = plotElementSystem(obj,tol,options)
    arguments
        obj
        tol = 1e-3
        options.Scale {mustBePositive} = 1.0 % 缩放倍数
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
    end
    ipoint = [obj.Line.IPoint];
    jpoint = [obj.Line.JPoint];
    OriginCoord = ([ipoint.Coord]+[jpoint.Coord])/2;
    [Norm_x,Norm_y,Norm_z] = obj.getElementSystem(tol);
    system_handle = Structure.plotSystem(OriginCoord,Norm_x,Norm_y,Norm_z,'Scale',options.Scale,'Figure',options.Figure,'Axis',options.Axis);
end