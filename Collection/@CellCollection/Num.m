function num = Num(obj)
    len = length(obj.ObjList);
    if len
        num = zeros(1,len);
        for i=1:len
            num(i) = obj.ObjList{i}.Num;
        end
    else
        num = [];
    end
end