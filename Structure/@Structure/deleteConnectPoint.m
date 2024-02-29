function deleteConnectPoint(obj,StructureObj)
    arguments
        obj
        StructureObj {mustBeA(StructureObj,'Structure')} = obj
    end
    if ~isempty(obj.ConnectPoint_Table)
        structure_list = obj.ConnectPoint_Table(:,2);
        for i=1:length(structure_list)
            if structure_list{i}==StructureObj
                obj.ConnectPoint_Table(i,:) = [];
            end
        end
    end
end