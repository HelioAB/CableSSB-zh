function span = Span(obj)
    coord_PointA = obj.PointA.Coord();
    coord_PointB = obj.PointB.Coord();
    span = abs(coord_PointB(1) - coord_PointA(1));
end