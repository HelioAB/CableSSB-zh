function merge(obj,tolerance)
    arguments
        obj
        tolerance {mustBeNumeric} = 1e-5
    end
    ijpoint = [obj.IPoint,obj.JPoint];
    uni_point = unique(ijpoint);
    [~,merged_index,used_point,discarded_point] = uni_point.merge(tolerance);
    for i=1:length(merged_index)
        if ~isempty(merged_index{i})
            [I_flag,J_flag] = obj.locatePoint(discarded_point{i});
            for j=1:length(discarded_point{i})
                if any(I_flag{j})
                    obj(I_flag{j}).edit('IPoint',used_point{i});
                end
                if any(J_flag{j})
                    obj(J_flag{j}).edit('JPoint',used_point{i});
                end
            end
        end
    end
end