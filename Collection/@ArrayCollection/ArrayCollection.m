classdef ArrayCollection < Collection
    methods
        % 所有继承DataRecord的类均需要操作ObjList属性，这样就解耦了 类对象 与 类的共用属性 
        % 注意DataRecord类定义中的ClassObj均为单个Obj，不是obj列表
        addObj(obj,ClassObj)
        deleteObj(obj,ClassObj)
        Obj = getObj(obj,PropertyName,PropertyValue)
        updateObjList(obj,PropertyName,ChangeTo)
        [sorted_objlist,Index] = sortObjList(obj,PropertyName)
        num = Num(obj)
        tf = isempty(obj)
    end
end