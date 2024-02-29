function [sorted_objlist,Index] = sortObjList(obj,PropertyName)
    arguments
        obj
        PropertyName (1,:) {mustBeText}
    end
    sorted_objlist = [];
    Index = [];
    % 只能根据属性值为数值类型的成员变量进行排序
    if length(obj.ObjList)
        sorting_list = [obj.ObjList.(PropertyName)];
        if isnumeric(sorting_list)
            [~,Index] = sort(sorting_list);
            sorted_objlist = obj.ObjList(Index);
        else
            error('仅支持根据数值类型的变量对ObjList排序')
        end
    end
end