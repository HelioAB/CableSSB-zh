function modifyPropertiesWhenSymmetrizing(obj)
    obj.Params.coord_A = obj.PointA.Coord;
    obj.Params.coord_B = obj.PointB.Coord;
    obj.Params.P_force_y = -obj.Params.P_force_y;
    obj.Params.P_y = -obj.Params.P_y;
    obj.ConnectPoint_Table = {};
end