function [section_list,index] = findSectionByName(obj,SectionName)
    [section_list,index] = obj.findObjListByName('Section',SectionName);
end