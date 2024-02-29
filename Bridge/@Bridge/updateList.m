function updateList(obj,ListName,Value)
    arguments
        obj
    end
    arguments(Repeating)
        ListName {mustBeMember(ListName,{'Structure','Section','Material','ElementType','ElementDivision','Coupling','Constraint','Load'})}
        Value
    end
    len = length(ListName);
    for i=1:len
        obj.addToList(ListName{i},Value{i});
    end
end