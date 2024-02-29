function line_list = findLineByCenterCoord(obj,component,direction)
    arguments
        obj
        component {mustBeMember(component,{'X','Y','Z'})}
        direction {mustBeMember(direction,{'ascend','descend'})} = 'ascend'
    end
    line = obj.Line;
    ipoint = [line.IPoint];
    jpoint = [line.JPoint];
    switch component
        case 'X'
            center_Coord = ([ipoint.X] + [jpoint.X])/2;
        case 'Y'
            center_Coord = ([ipoint.Y] + [jpoint.Y])/2;
        case 'Z'
            center_Coord = ([ipoint.Z] + [jpoint.Z])/2;
    end
    [~,index] = sort(center_Coord);
    line_list = line(index);
end