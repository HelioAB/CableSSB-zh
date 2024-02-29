function point_table = Info(obj)
    len = length(obj);
    point_table = cell(len,4);
    if ~isempty(obj)
        Num = [obj.Num]';
        x = [obj.X]';
        y = [obj.Y]';
        z = [obj.Z]';
        point_table(:,1:4) = num2cell([Num,x,y,z]);
    end
end