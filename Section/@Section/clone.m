function newobj = clone(obj)
    newobj = Section(obj.Name);
    newobj.Num = obj.Num;
    newobj.SectionData = obj.SectionData;
end