function newobj = clone(obj)
    IPoint,JPoint,section,material
    newobj = Hanger(IPoint,JPoint,obj.Section,obj.Material);
end