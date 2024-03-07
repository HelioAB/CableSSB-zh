function newobj = clone(obj)
    IPoint = obj.IPoint.clone();
    JPoint = obj.JPoint.clone();
    newobj = Hanger(IPoint,JPoint,obj.Section,obj.Material);
end