function tf = isempty(obj)
    if length(obj)==0
        tf= true;
    elseif isempty(obj.SectionData) % SectionProperty属性为空(该属性的isempty会自己重载)时，Section就为空
        tf = true;
    else
        tf = false;
    end
end