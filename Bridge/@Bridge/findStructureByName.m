function [structure_list,index] = findStructureByName(obj,StructureName)
    [structure_list,index] = obj.findObjListByName('Structure',StructureName);
end