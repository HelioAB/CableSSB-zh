function count_line = getLineCountOfClass(obj,StructureClass)
    arguments
        obj
        StructureClass {mustBeMember(StructureClass,{'StayedCable','Hanger','Girder','Cable','RigidBeam','Tower','Pier'})}
    end
    structure_list = obj.findStructureByClass(StructureClass);
    count_line = 0;
    for i=1:length(structure_list)
        count_line = count_line + length(structure_list{i}.Line);
    end
end