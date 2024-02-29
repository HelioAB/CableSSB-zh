function ConnectIndex = Index_Connect(obj,StructureObj)
    arguments
        obj
        StructureObj {mustBeA(StructureObj,'Structure')}
    end
    point_list = obj.ConnectPoint_Table(:,1);
    structure_list = obj.ConnectPoint_Table(:,2);
    point = obj.Point;
    ConnectIndex = false(1,length(point));
    for i=1:length(structure_list)
        if structure_list{i}==StructureObj
            Connect_Point = point_list{i};
        end
    end
    if ~isempty(Connect_Point)
        for i=1:length(Connect_Point)
            ConnectIndex = ConnectIndex | (Connect_Point(i)==point);
        end
    end
end