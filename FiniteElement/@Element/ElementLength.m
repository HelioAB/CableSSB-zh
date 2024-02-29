function len = ElementLength(obj)
    inode = [obj.INode];
    jnode = [obj.JNode];
    len = sqrt(([jnode.X]-[inode.X]).^2+([jnode.Y]-[inode.Y]).^2+([jnode.Z]-[inode.Z]).^2);
end