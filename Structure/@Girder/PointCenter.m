function point_center = PointCenter(obj)
    girder_point = obj.Point;
    len = length(girder_point);
    if mod(len,2) == 1 % 如果为奇数
        point_center = girder_point((len+1)/2);
    elseif mod(len,2) == 0 % 如果为偶数
        point_center = girder_point(len/2);
    end
end