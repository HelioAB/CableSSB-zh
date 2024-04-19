function coord_centerpoint = getCenterPointCoord(obj)
    inodes = [obj.INode];
    jnodes = [obj.JNode];
    coord_centerpoint = ([inodes.Coord]+[jnodes.Coord])/2;
end