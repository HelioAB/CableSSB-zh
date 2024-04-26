function output(obj,options)
    arguments
        obj
        options.ifSaveBridgeObj = false % 是否需要存储bridgeobj
        options.ifClearCollection = false % 是否需要清理Collection.ObjList
    end
    if isempty(obj.OutputMethod)
        error('还没有定义输出方法，请给本Bridge对象的OutputMethod属性定义一个OutputTo对象')
    end
    output_method = obj.OutputMethod;
    obj.OutputMethod.OutputObj = obj;
    output_method.action('ifSaveBridgeObj',options.ifSaveBridgeObj,'ifClearCollection',options.ifClearCollection);
end