function point_A = PointA(obj)
    point = obj.Point;
    if ~isempty(point)
        sorted_point = point.sort('X');
        point_A = sorted_point(1);
    end
end