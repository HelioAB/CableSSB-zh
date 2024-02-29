function Obj = getObj(obj,PropertyName,PropertyValue)
    metaobj = metaclass(obj.ObjList);
    props = {metaobj.PropertyList.Name};
    if any(strcmp(props,PropertyName))
        Obj = findobj(obj.ObjList,PropertyName,PropertyValue);
        if isempty(Obj)
            warning('没有找到属性为指定值的对象')
        end
    else
        error('不存在指定的属性名称')
    end
end