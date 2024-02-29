function updateObjList(obj,PropertyName,ChangeTo)
    arguments
        obj
        PropertyName (1,:) {mustBeText}
        ChangeTo
    end
    len = length(obj.ObjList);
    if length(ChangeTo)~=len
        error('更新后的值的向量长度必须等于ObjList长度')
    end
    metaobj = metaclass(obj.ObjList);
    props = {metaobj.PropertyList.Name};
    if any(strcmp(props,PropertyName))
        for i=1:len
            obj.editObj(obj.ObjList(i),PropertyName,ChangeTo(i))
        end
    else
        error('不存在指定的属性名称')
    end
end