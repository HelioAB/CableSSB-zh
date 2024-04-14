classdef Collection < handle
    properties(SetAccess=protected)
        ObjList
    end
    methods(Abstract)
        % 所有继承DataRecord的类均需要操作ObjList属性，这样就解耦了 类对象 与 类的共用属性 
        % 注意DataRecord类定义中的ClassObj均为单个Obj，不是obj列表
        addObj()
        deleteObj()
        getObj()
        updateObjList()
        sortObjList()
        isempty()
        Num()
        deleteAll()
    end
end