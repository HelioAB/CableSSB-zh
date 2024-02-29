function output(obj)
    if ~isempty(obj.OutputMethod)
        output_method = obj.OutputMethod;
        obj.OutputMethod.OutputObj = obj;
        output_method.action;
        assignin("base","OutputMethod",output_method)
    else
        error('还没有定义输出方法，请给本Bridge对象的OutputMethod属性定义一个OutputTo对象')
    end
   
end