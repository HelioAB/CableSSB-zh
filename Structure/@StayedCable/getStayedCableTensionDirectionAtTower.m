function [dir_tower_tension,sign_tower_tension] = getStayedCableTensionDirectionAtTower(obj)
    tower_point = obj.findTowerPoint;
    girder_point = obj.findGirderPoint;
    tower_point_coord = tower_point.Coord;% n*3的矩阵
    girder_point_coord = girder_point.Coord;
    dir_tower_tension = normalize(tower_point_coord - girder_point_coord,2,'norm',2);
    sign_tower_tension = sign(dir_tower_tension);
end