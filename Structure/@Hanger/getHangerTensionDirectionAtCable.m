function [dir_cable_tension,sign_cable_tension] = getHangerTensionDirectionAtCable(obj)
    % 输出：hanger与cable交点处，hanger受力为拉力的方向。
    cable_point = obj.findCablePoint;
    girder_point = obj.findGirderPoint;
    cable_point_coord = cable_point.Coord;% n*3的矩阵
    other_point_coord = girder_point.Coord;
    dir_cable_tension = normalize(cable_point_coord - other_point_coord,2,'norm',2);
    sign_cable_tension = sign(dir_cable_tension);
end