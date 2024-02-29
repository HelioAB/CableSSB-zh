function deleteObj(obj,ClassObj)
    index = false(1,length(obj.ObjList));
    for i=1:length(obj.ObjList)
        if obj.ObjList{i} == ClassObj
            index(i) = true;
        end
    end
    if any(index)
        obj.ObjList(index) = [];
    end
end