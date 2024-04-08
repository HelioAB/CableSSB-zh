function newobj = clone(obj)
    IPoint = obj.IPoint.clone();
    JPoint = obj.JPoint.clone();
    newobj = Hanger(IPoint,JPoint,obj.Section,obj.Material);
    newobj.ConnectPoint_Table = obj.ConnectPoint_Table;
end