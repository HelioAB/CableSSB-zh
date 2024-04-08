function girder_points = findGirderPoint(obj)
    connect_table = obj.ConnectPoint_Table;
    sz = size(connect_table);
    girder_points = [];
    
    for i=1:sz(1)
        if isa(connect_table{i,2},'RigidBeam')
            girder_points = connect_table{i,1};
        end
    end
end