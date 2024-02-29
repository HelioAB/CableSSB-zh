function [exi_num,exi_obj,exi_index,nonexi_obj] = findExisting(obj)
    objlist_num = obj.Collection.Num;
    exi_num = []; 
    exi_obj = {};
    exi_index = {};
    nonexi_obj = [];
    if ~isempty(obj) && ~isempty(objlist_num)
        % ObjList中没有
        obj_num = [obj.Num];
        Exists_index = false(size(obj_num));
        for i=1:length(objlist_num)
            index = objlist_num(i) == obj_num;
            if any(index)
                exi_num(end+1) = objlist_num(i);
                exi_obj{end+1} = obj(index);
                exi_index{end+1} = index;
            end
            Exists_index = Exists_index|index;
        end
        nonexi_obj = obj(~Exists_index);
    elseif isempty(objlist_num)
        nonexi_obj = obj;
    end
end