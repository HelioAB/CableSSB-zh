function move(obj,RefPoint,Coord_MoveTo)
    % 坐标移动到MoveTo
    arguments
        obj
        RefPoint (1,1) {mustBeA(RefPoint,'Point')}
        Coord_MoveTo (:,3) {mustBeNumeric}
    end 
    diff = Coord_MoveTo - RefPoint.Coord;
    obj.translate(diff);
end