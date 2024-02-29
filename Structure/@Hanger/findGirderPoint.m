function girder_points = findGirderPoint(obj)
    lines = obj.Line;
    len_lines = length(lines);
    girder_points = Point.empty;
    girder_points(1,len_lines).Num = [];
    for i=1:len_lines
        ipoint = lines(i).IPoint;
        jpoint = lines(i).JPoint;
        if ipoint.Z < jpoint.Z
            girder_points(i) = ipoint;
        else
            girder_points(i) = jpoint;
        end
    end
end