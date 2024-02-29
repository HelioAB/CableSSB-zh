function obj_list = findObjByNum(obj,num)
    arguments
        obj
        num {mustBeInteger}
    end
    len = length(num);
    if len
        obj_list = obj.empty(0,len);
        obj_list(len).Num = [];
        map = obj.getMap;
        key = cell2mat(keys(map));
        for i=1:len
            if any(num(i)==key)
                obj_list(1,i) = map(num(i));
            end
        end
    else
        obj_list = [];
    end
    
end