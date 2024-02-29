function deleteObj(obj,ClassObj)
    index = (obj.ObjList==ClassObj);
    if any(index)
        obj.ObjList(index) = [];
    end
end