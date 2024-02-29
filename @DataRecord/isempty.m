function tf = isempty(obj)
    if isempty([obj.Num])
        tf = true;
    else
        tf = false;
    end
end