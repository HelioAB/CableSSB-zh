function [sorted_objlist,Index] = sortObjList(obj)
    sorted_objlist = {};
    Index = [];
    % 只能根据属性值为数值类型的成员变量进行排序
    if ~isempty(obj.ObjList)
        sorting_list = cellfun(@(Object) Object.Num,obj.ObjList);
        [~,Index] = sort(sorting_list);
        sorted_objlist = obj.ObjList(Index);
    end
end