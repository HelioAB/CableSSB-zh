function addToList(obj,ListClassName,value)
    arguments
        obj
        ListClassName {mustBeMember(ListClassName,{'Material','Section','ElementType','ElementDivision','Structure','Coupling','Constraint','Load'})}
        value
    end
    ListName = [ListClassName,'List'];
    obj.(ListName){1,end+1} = value;
end