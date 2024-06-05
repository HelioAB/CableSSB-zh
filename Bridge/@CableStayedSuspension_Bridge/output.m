function output(obj,options)
    arguments
        obj
        options.ifSaveBridgeObj = false % 是否需要存储bridgeobj
        options.ifClearCollection = false % 是否需要清理Collection.ObjList
    end
    if ~isempty(obj.OutputMethod)
        output_method = obj.OutputMethod;
        obj.OutputMethod.OutputObj = obj;
        % 输出文件
        output_method.outputElementType;
        output_method.outputMaterial;
        output_method.outputSection;
        output_method.outputReal;
        output_method.outputKeyPoint;
        output_method.outputLine;
        output_method.outputLineAttribution;
        output_method.outputLineMesh;
        output_method.outputConstraint;
        output_method.outputLoad;
        output_method.outputCoupling;
        output_method.outputSolve('nlgeom','on','sstif','on','nsubst',[1,0,0]);
        output_method.outputMain;
    else
        error('还没有定义输出方法，请给本Bridge对象的OutputMethod属性定义一个OutputTo对象')
    end
    if options.ifSaveBridgeObj
        bridge = obj;
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