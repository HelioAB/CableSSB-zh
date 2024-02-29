function girder_point = findGirderPoint(obj)
    connect_table = obj.ConnectPoint_Table;
    point1 = connect_table{1,1};
    point2 = connect_table{2,1};
    point1_coord = point1.Coord;
    point2_coord = point2.Coord;
    if point1_coord(:,3) > point2_coord(:,3)
        girder_point = point2;
    else
        girder_point = point1;
    end
end