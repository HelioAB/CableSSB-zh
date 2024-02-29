function [delta_x,delta_y,delta_z] = DeltaLength(obj)
    ipoint = [obj.IPoint];
    jpoint = [obj.JPoint];
    delta_x = [jpoint.X]-[ipoint.X];
    delta_y = [jpoint.Y]-[ipoint.Y];
    delta_z = [jpoint.Z]-[ipoint.Z];
end