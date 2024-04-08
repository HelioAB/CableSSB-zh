function cable_points = findCablePoint(obj)
    connect_table = obj.ConnectPoint_Table;
    sz = size(connect_table);
    cable_points = [];
    for i=1:sz(1)
        if isa(connect_table{i,2},'Cable')
            cable_points = connect_table{i,1};
        end
    end
end