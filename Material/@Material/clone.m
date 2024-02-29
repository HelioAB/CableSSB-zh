function newobj = clone(obj)
    newobj = Material(obj.Name);
    newobj.Num = obj.Num;
    newobj.MaterialData = obj.MaterialData;
end