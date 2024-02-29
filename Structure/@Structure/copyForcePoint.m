function copied_forcepoint = copyForcePoint(obj,ToObj)
    index = obj.Index_Force;
    if sum(index)==0
        copied_forcepoint = Point.empty;
    else
        copied_forcepoint = ToObj.Point(index);
    end
end