function [delta_x,delta_y,delta_z] = DeltaLength(obj)
    inode = [obj.INode];
    jnode = [obj.JNode];
    delta_x = [jnode.X]-[inode.X];
    delta_y = [jnode.Y]-[inode.Y];
    delta_z = [jnode.Z]-[inode.Z];
end