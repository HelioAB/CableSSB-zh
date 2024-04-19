function coord_centerpoint = getCenterPointCoord(obj)
    ipoint = [obj.IPoint];
    jpoint = [obj.JPoint];
    coord_centerpoint = ([ipoint.Coord]+[jpoint.Coord])/2;
end