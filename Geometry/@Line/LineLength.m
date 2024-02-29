function len = LineLength(obj)
    ipoint = [obj.IPoint];
    jpoint = [obj.JPoint];
    len = sqrt(([jpoint.X]-[ipoint.X]).^2+([jpoint.Y]-[ipoint.Y]).^2+([jpoint.Z]-[ipoint.Z]).^2);
end