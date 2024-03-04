function newobj = clone(obj)
    IPoint,JPoint,section,material
    newobj = Hanger(obj.IPoint,obj.JPoint,obj.Section,obj.Material);
end