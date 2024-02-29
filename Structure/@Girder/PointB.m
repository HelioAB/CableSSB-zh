function point_B = PointB(obj)
    point = obj.Point;
    if ~isempty(point)
        sorted_point = point.sort('X');
        point_B = sorted_point(end);
    end
end