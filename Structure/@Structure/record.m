function record(obj)
    if isempty(obj.NewPoint)
        newpoint = obj.Point.findUnrecord();
        obj.NewPoint = newpoint;
    else
        newpoint = obj.NewPoint.findUnrecord();
    end
    if ~isempty(newpoint)
        newpoint.record;
    end
    
    if isempty(obj.NewLine)
        newline = obj.Line.findUnrecord();
        obj.NewLine = newline;
    else
        newline = obj.NewLine.findUnrecord();
    end
    if ~isempty(newline)
        newline.record;
    end
end