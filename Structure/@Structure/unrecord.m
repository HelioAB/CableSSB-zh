function unrecord(obj)
    newpoint = obj.NewPoint;
    if ~isempty(newpoint)
        newpoint.unrecord();
    end
    newline = obj.NewLine;
    if ~isempty(newline)
        newline.unrecord();
    end
end