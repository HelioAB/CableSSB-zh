function editStructureName(obj,StructureObj,Name)
    arguments
        obj
        StructureObj (1,1)
        Name {mustBeText}= ''
    end
    class_name = metaclass(StructureObj).Name;
    class_list = obj.findStructureByClass(class_name);
    class_count = length(class_list);
    if isempty(Name)
        StructureObj.Name = [class_name,'_',num2str(class_count)]; % StructureName的默认值：先把StructureObj放进StructureList，再计数
    else
        StructureObj.Name = char(Name);
    end
end