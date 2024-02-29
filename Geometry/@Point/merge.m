function [merged_point,merged_index,used_point,discarded_point] = merge(obj,tolerance)
    % obj为Point对象数组
    % tolerance为容许误差
    % 保留先定义的Point对象
    arguments
        obj
        tolerance {mustBeNumeric} = 1e-5
    end
    x = [obj.X];
    y = [obj.Y];
    z = [obj.Z];
    loop_flag = false(size(obj));
    merged_point(size(obj)) = Point();
    merged_index = cell(1,length(obj));
    used_point = cell(1,length(obj));
    discarded_point = cell(1,length(obj));
    for i=1:length(obj)
        if loop_flag(i)
            continue
        end
        index = (sqrt((x-x(i)).^2 + (y-y(i)).^2 + (z-z(i)).^2) < tolerance);
        if sum(index)>=2
            merged_index{1,i} = index;
            used_point{1,i} = obj(i);
            temp_point = obj(index);
            discarded_point{1,i} = temp_point(2:end);
        end
        merged_point(index) = obj(i); % 所有位置相近的点都赋值为obj中首先出现的那个
        loop_flag(index) = true;
    end
end