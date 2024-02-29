function structure_list = findConnectStructureByClass(obj,class_name)
    connect_table = obj.ConnectPoint_Table;
    sz = size(connect_table);
    structure_list = [];
    for i=1:sz(1)
        if isa(connect_table{i,2},class_name)
            structure_list = [structure_list,connect_table{i,2}];
        end
    end
end