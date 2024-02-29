function [material_list,index] = findElementTypeByName(obj,ElementTypeName)
    [material_list,index] = obj.findObjListByName('ElementType',ElementTypeName);
end