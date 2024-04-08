function girder_point = findGirderPoint(obj)
    connect_table = obj.ConnectPoint_Table;
    sz = size(connect_table);
    girder_point = [];
    for i=1:sz(1)
        connect_structure = connect_table{i,2};
        if isa(connect_structure,'Girder')
            girder_point = connect_table{i,1};
        end
    end
end