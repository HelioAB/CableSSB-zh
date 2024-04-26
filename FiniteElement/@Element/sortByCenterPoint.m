function [sorted_elems,index] = sortByCenterPoint(obj,Direction)
    arguments
        obj
        Direction {mustBeMember(Direction,{'X','Y','Z'})}
    end
    % 通过elements的中心点位置进行排序
    coord_center = obj.getCenterPointCoord;
    switch Direction
        case 'X'
            sort_ref_coord = coord_center(:,1);
        case 'Y'
            sort_ref_coord = coord_center(:,2);
        case 'Z'
            sort_ref_coord = coord_center(:,3);
    end
    [~,index] = sort(sort_ref_coord);
    sorted_elems = obj(index);
end