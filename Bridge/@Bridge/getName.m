function name = getName(obj,ListClassName)
    arguments
        obj
        ListClassName {mustBeMember(ListClassName,{'Material','Section','ElementType','ElementDivision','Structure','Coupling','Constraint','Load'})}
    end
    ListName = [ListClassName,'List'];
    list = obj.(ListName);
    len = length(list);
    name = cell(1,len);
    for i=1:len
        list_obj = list{i};
        if length(list_obj)==1
            name{i} = list_obj.Name;
        elseif length(list_obj)>1
            name{i} = list_obj(1).Name;
        end
    end
end