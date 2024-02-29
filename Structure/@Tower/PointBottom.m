function point_bottom = PointBottom(obj)
    point = obj.Point;
    if ~isempty(point)
        sorted_point = point.sort('Z');
        point_bottom = sorted_point(1);
    end
end