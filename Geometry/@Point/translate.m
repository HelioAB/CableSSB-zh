function translate(obj,difference)
    % 坐标移动了difference
    arguments
        obj
        difference (:,3) {mustBeNumeric}
    end
    len = length([obj.Num]);
    size_diff = size(difference);
    switch size_diff(1)
        case 1 % 如果修改差值Difference为标量
            for i=1:len
                obj(1,i).X = obj(1,i).X + difference(1,1);
                obj(1,i).Y = obj(1,i).Y + difference(1,2);
                obj(1,i).Z = obj(1,i).Z + difference(1,3);
            end
        case len % 如果修改差值Difference为向量，且该向量与待修改向量长度相同
            for i=1:len
                obj(1,i).X = obj(1,i).X + difference(i,1);
                obj(1,i).Y = obj(1,i).Y + difference(i,2);
                obj(1,i).Z = obj(1,i).Z + difference(i,3);
            end
        otherwise
            error('difference的size应该为(1,3) 或 (length(obj),3)')
    end
end