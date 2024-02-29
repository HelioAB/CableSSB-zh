function output(obj)
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
end