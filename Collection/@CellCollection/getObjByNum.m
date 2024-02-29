function obj_list = getObjByNum(obj,Num)
    obj_list = {};
    for i=1:length(obj.ObjList)
        if obj.ObjList{i}.Num == Num
            obj_list = [obj_list,{obj.ObjList{i}}];
        end
    end
end