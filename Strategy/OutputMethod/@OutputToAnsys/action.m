function action(obj,options)
    arguments
        obj
        options.ifSaveBridgeObj = false % 是否需要存储bridgeobj
        options.ifClearCollection = false % 是否需要清理Collection.ObjList
    end
    % 输出文件
    obj.outputElementType;
    obj.outputMaterial;
    obj.outputSection;
    obj.outputReal;
    obj.outputKeyPoint;
    obj.outputLine;
    obj.outputLineAttribution;
    obj.outputLineMesh;
    obj.outputConstraint;
    obj.outputLoad;
    obj.outputCoupling;
    obj.outputSolve;
    obj.outputMain;
    bridge = obj.OutputObj;
    if options.ifSaveBridgeObj
        save(fullfile(obj.OutputMethod.WorkPath,'BridgeObj.mat'),'bridge');
    end
    if options.ifClearCollection
        % 清除Collection.ObjList
        Point.Collection.deleteAll();
        Line.Collection.deleteAll();
        Constraint.Collection.deleteAll();
        Coupling.Collection.deleteAll();
        Element.Collection.deleteAll();
        ElementType.Collection.deleteAll();
        Load.Collection.deleteAll();
        Material.Collection.deleteAll();
        Node.Collection.deleteAll();
        Section.Collection.deleteAll();
    end
end