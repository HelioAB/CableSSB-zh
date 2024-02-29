function point_top = PointTop(obj)
    point = obj.Point;
    if ~isempty(point)
        sorted_point = point.sort('Z');
        point_top = sorted_point(end);
    end
end