function cable_points = findCablePoint(obj)
    lines = obj.Line;
    len_lines = length(lines);
    cable_points = Point.empty;
    cable_points(1,len_lines).Num = [];
    for i=1:len_lines
        ipoint = lines(i).IPoint;
        jpoint = lines(i).JPoint;
        if ipoint.Z > jpoint.Z
            cable_points(i) = ipoint;
        else
            cable_points(i) = jpoint;
        end
    end
end