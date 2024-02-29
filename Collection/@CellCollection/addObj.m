function addObj(obj,ClassObj)
    if isempty(obj.ObjList)
        obj.ObjList = {ClassObj};
    else
        obj.ObjList(1,end+1) = {ClassObj};
    end
end