function [X,sorted_point] = getSortedGirderPointXCoord(obj,StrucutreList)   
    % 获得StayedCable和Hanger的 GirderPoint 及其 X坐标（经过了unique）
    point = [];
    for i=1:length(StrucutreList)
        mustBeA(StrucutreList{i},{'StayedCable','Hanger'})
        point = [point,StrucutreList{i}.findGirderPoint];
    end
    sorted_point = point.sort('X');
    coord_sorted_point = sorted_point.Coord;
    x_sorted_point = coord_sorted_point(:,1)';
    X = uniquetol(x_sorted_point,1e-5);
end