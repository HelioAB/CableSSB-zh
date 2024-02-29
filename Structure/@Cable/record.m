function record(obj)
    if length(obj.Line) >= 1 % 至少要有一条Line才非空
        % 如果A点和B点坐标都为同一点，代表这个Cable是一个空Cable,不record空的Cable
        if sqrt(sum((obj.PointA.Coord-obj.PointB.Coord).^2)) > Structure.compare_tolerance
            record@Structure(obj);
        end
    end
end