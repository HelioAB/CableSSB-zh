function line_table = Info(obj)
    len = length(obj);
    line_table = cell(len,3);
    if ~isempty(obj)
        Num = [obj.Num]';
        ipoint = [obj.IPoint]';
        jpoint = [obj.JPoint]';
        line_table(:,1:3) = num2cell([Num,[ipoint.Num]',[jpoint.Num]']);
    end
end