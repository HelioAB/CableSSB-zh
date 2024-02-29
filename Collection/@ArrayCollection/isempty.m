function tf = isempty(obj)
    if length(obj.ObjList)% 不能按matlab建议的使用isempty，因为isempty方法已经被各个类重载了
        tf = false;
    else
        tf = true;
    end
end