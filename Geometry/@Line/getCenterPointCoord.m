function centerpoint = getCenterPointCoord(obj)
    ipoint = [obj.IPoint];
    jpoint = [obj.JPoint];
    centerpoint = ([ipoint.Coord]+[jpoint.Coord])/2;
end