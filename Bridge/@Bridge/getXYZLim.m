function [XLim,YLim,ZLim] = getXYZLim(obj)
    points = obj.getAllPoints();
    X_points = [points.X];
    Y_points = [points.Y];
    Z_points = [points.Z];
    XLim = [min(X_points),max(X_points)];
    YLim = [min(Y_points),max(Y_points)];
    ZLim = [min(Z_points),max(Z_points)];
end