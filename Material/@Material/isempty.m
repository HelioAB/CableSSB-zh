function tf = isempty(obj)
    if length(obj)==0
        tf = true;
    elseif isempty(obj.MaterialData)% MaterialProperty属性为空(该属性的isempty会自己重载)时，Material就为空
        tf = true;
    else
        tf = false;
    end
end