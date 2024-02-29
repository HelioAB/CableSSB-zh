function [structure_list,index] = findStructureByClass(obj,StructureClass)
    % 寻找Bridge对象中的所有类为StructureClass的Structure对象
    arguments
        obj
        StructureClass {mustBeText} = ''
    end
    index = false(1,length(obj.StructureList));
    if ~isempty(StructureClass)
        for i=1:length(obj.StructureList)
            if strcmpi(class(obj.StructureList{i}),StructureClass)
                index(i) = true;
            end
        end
    end
    structure_list = obj.StructureList(index);
end