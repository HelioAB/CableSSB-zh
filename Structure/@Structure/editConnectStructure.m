function editConnectStructure(obj,FromStructure,ToStructure)
    arguments
        obj
        FromStructure {mustBeA(FromStructure,'Structure')}
        ToStructure {mustBeA(ToStructure,'Structure')}
    end
    connect_point_table = obj.ConnectPoint_Table;
    if isempty(connect_point_table)
    else
        structure_list = connect_point_table(:,2);
        for i=1:length(structure_list)
            if structure_list{i}==FromStructure % 如果StructureObj已经存在于ConnectPoint_Table中
                obj.ConnectPoint_Table{i,2} = ToStructure;
            end
        end
    end
end