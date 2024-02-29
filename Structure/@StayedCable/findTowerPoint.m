function tower_points = findTowerPoint(obj)
    lines = obj.Line;
    len_lines = length(lines);
    tower_points = Point.empty;
    tower_points(1,len_lines).Num = [];
    for i=1:len_lines
        ipoint = lines(i).IPoint;
        jpoint = lines(i).JPoint;
        if ipoint.Z > jpoint.Z
            tower_points(i) = ipoint;
        else
            tower_points(i) = jpoint;
        end
    end
end