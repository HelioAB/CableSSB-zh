function create(obj)
    if ~isempty(obj.Method_Creating)
        obj.Line = obj.Method_Creating.action;
        obj.NewPoint = obj.Point.findUnrecord();
        obj.NewLine = obj.Line.findUnrecord();
    else
        error('还没有指定Method_Creating属性，无法创建Pier对象的Point和Line')
    end
end