function [obj_list,index] = findObjListByName(obj,ListClassName,Name)
    arguments
        obj
        ListClassName {mustBeMember(ListClassName,{'Material','Section','ElementType','ElementDivision','Structure','Coupling','Constraint','Load'})}
        Name {mustBeText} = ''
    end
    obj_list = [];
    if ~isempty(Name)
        list_name = [ListClassName,'List'];
        list = obj.(list_name);
        index = false(1,length(list));
        for i=1:length(list)
            if strcmp(list{i}(1).Name,Name)
                index(i) = true;
            end
        end
        obj_list = obj.(list_name)(index);
    end
end