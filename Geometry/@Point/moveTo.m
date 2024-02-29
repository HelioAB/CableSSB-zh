function moveTo(obj,coord)
    % 坐标移动到
    arguments
        obj
        coord (:,3) {mustBeNumeric}
    end
    len = length([obj.Num]);
    size_coord = size(coord);
    switch size_coord(1)
        case 1 % 如果Coord只输入
            for i=1:len
                obj(1,i).X = coord(1,1);
                obj(1,i).Y = coord(1,2);
                obj(1,i).Z = coord(1,3);
            end
        case len
            for i=1:len
                obj(1,i).X = coord(i,1);
                obj(1,i).Y = coord(i,2);
                obj(1,i).Z = coord(i,3);
            end
        otherwise
            error('ChangeTo的size应该为(1,3) 或 (length(obj),3)')
    end
end