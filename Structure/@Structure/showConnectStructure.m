function StructureObj = showConnectStructure(obj)
    connect_point_table = obj.ConnectPoint_Table;
    sz = size(connect_point_table);
    StructureObj = cell(1,sz(1));
    if isempty(connect_point_table)
    else
        structure_list = connect_point_table(:,2);
        for i=1:length(structure_list)
            StructureObj{i} = structure_list{i};
        end
    end
end