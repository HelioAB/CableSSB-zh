function [point_list,index_list] = findPointByCoord(obj,X,Y,Z,tolerance)
    % 通过精确的坐标Coord，在obj（Point对象数组）中找到满足tolerance的Point对象
    arguments
        obj
        X (1,:) {mustBeNumeric}
        Y (1,:) {mustBeNumeric,mustBeEqualSize(X,Y)}
        Z (1,:) {mustBeNumeric,mustBeEqualSize(X,Z)}
        tolerance {mustBeNumeric} = 1e-5
    end
    x = [obj.X];
    y = [obj.Y];
    z = [obj.Z];
    len = length(X);
    point_list = cell(1,len);
    index_list = cell(1,len);
    for i=1:length(X)
        index = (sqrt((x-X(i)).^2 + (y-Y(i)).^2 + (z-Z(i)).^2) < tolerance);
        point_list{i} = obj(index);
        index_list{i} = index;
    end
end