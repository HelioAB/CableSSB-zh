function sortedPoints = sortByDistance(obj,reference)
    arguments
        obj (1,:) % 在该Point对象数组中寻找点
        reference % 参考点，在obj中寻找与ref_point距离最近的点
    end
    if isa(reference,'Point')
        if length(reference)==1
            Coord_ref = reference.Coord();
        else
            error('如果输入的reference为Point对象，那么其长度应该为1')
        end
    else
        mustBeNumeric(reference);
        if length(reference) == 3
            Coord_ref = reference;
        else
            error('如果输入的reference为数值数组，那么其长度应该为3')
        end
    end
    Coord = obj.Coord();
    deltaX = Coord(:,1)-Coord_ref(1);
    deltaY = Coord(:,2)-Coord_ref(2);
    deltaZ = Coord(:,3)-Coord_ref(3);
    distance_square = (deltaX.^2 + deltaY.^2 + deltaZ.^2);
    [~,index] = sort(distance_square);
    sortedPoints = obj(index);
end