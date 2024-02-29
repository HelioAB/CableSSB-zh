function tf = isempty(obj)
    if isempty(obj.ObjList)
        tf = true;
    else
        tf = false;
    end
end