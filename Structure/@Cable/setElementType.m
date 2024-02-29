function element_type = setElementType(obj,val)
    if isa(val,'Link10')
        element_type = val;
    else
        error('Cable结构的Element Type必须为Link10')
    end
end 