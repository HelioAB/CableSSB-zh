function [uni_obj,obj2uni_index,uni2obj_index] = unique(obj)
    % 重载Matlab内置函数unique，用法几乎一样，不过输入输出均为DataRecord对象
    obj_num = [obj.Num];
    [~,obj2uni_index,uni2obj_index] = unique(obj_num);
    uni_obj = obj(obj2uni_index);
end