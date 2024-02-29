function [point,index] = findPointByRange(obj,XRange,YRange,ZRange,tolerance)
    % Range有3种输入方法：
    %   1. length == 0, 没有Range限制 
    %   2. length == 1, 找到这个Coord处的Point对象
    %   3. length == 2, 找到Coord处于Range(1)到Range(2)之间的Point对象
    %       支持输入inf代表某一边没有要求

    arguments
        obj
        XRange {mustBeNumeric} = []
        YRange {mustBeNumeric} = []
        ZRange {mustBeNumeric} = []
        tolerance {mustBeNumeric} = 1e-5
    end
    x = [obj.X];
    y = [obj.Y];
    z = [obj.Z];
    
    % XRange的处理
    len_X = length(XRange);
    if len_X == 0
        x_index = true(size(obj));
    elseif len_X == 1
        x_index = (abs(x-XRange) < tolerance);
    elseif len_X == 2
        if XRange(1) > XRange(2) % 如果Range的第1个数大于等于第2个数
            error('XRange的第1个数应该小于第2个数')
        elseif XRange(1) == XRange(2) % 如果Range的两个数相等，同len_X==1的情况
            x_index = (abs(x-XRange) < tolerance);
        else
            x_index = (x>=XRange(1)) & (x<=XRange(2));
        end
    else
        error('参数XRange的长度应该为0, 1或2')
    end
    
    % YRange的处理
    len_Y = length(YRange);
    if len_Y == 0
        y_index = true(size(obj));
    elseif len_Y == 1
        y_index = (abs(y-YRange) < tolerance);
    elseif len_Y == 2
        if YRange(1) > YRange(2) % 如果Range的第1个数大于等于第2个数
            error('YRange的第1个数应该小于第2个数')
        elseif YRange(1) == YRange(2) % 如果Range的两个数相等，同len_X==1的情况
            y_index = (abs(y-YRange) < tolerance);
        else
            y_index = (y>=YRange(1)) & (y<=YRange(2));
        end
    else
        error('参数YRange的长度应该为0, 1或2')
    end
    
    % ZRange的处理
    len_Z = length(ZRange);
    if len_Z == 0
        z_index = true(size(obj));
    elseif len_Z == 1
        z_index = (abs(z-ZRange) < tolerance);
    elseif len_Z == 2
        if ZRange(1) > ZRange(2) % 如果Range的第1个数大于等于第2个数
            error('ZRange的第1个数应该小于第2个数')
        elseif ZRange(1) == ZRange(2) % 如果Range的两个数相等，同len_X==1的情况
            z_index = (abs(z-ZRange) < tolerance);
        else
            z_index = (z>=ZRange(1)) & (z<=ZRange(2));
        end
    else
        error('参数ZRange的长度应该为0, 1或2')
    end
    % 同时满足XRange, YRange, ZRange的index和Point对象
    index = x_index & y_index & z_index;
    point = obj(index);
end