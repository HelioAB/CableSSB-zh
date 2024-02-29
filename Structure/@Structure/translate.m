function translate(obj,difference)
    % 坐标移动了difference
    % difference可以为(1,3)，也可以为(length(obj.Point),3)
    obj.Point.translate(difference)
end