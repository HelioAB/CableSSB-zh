function Connect_Point = ConnectPoint(obj,StructureObj)
    arguments
        obj
        StructureObj {mustBeA(StructureObj,'Structure')} = obj
    end
    if ~isempty(obj.ConnectPoint_Table)
        point_list = obj.ConnectPoint_Table(:,1);
        structure_list = obj.ConnectPoint_Table(:,2);
        Connect_Point = [];
        for i=1:length(structure_list)
            if structure_list{i}==StructureObj
                Connect_Point = point_list{i};
            end
        end
    else
        Connect_Point = [];
    end
end