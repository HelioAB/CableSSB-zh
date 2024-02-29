function num = Num(obj)
    len = length(obj.ObjList);
    if len
        num = [obj.ObjList.Num];
    else
        num = [];
    end
end