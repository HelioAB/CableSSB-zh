function [material_list,index] = findMaterialByName(obj,MaterialName)
    [material_list,index] = obj.findObjListByName('Material',MaterialName);
end