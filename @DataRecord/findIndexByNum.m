function num_index = findIndexByNum(obj,Num)
    arguments
        obj
        Num {mustBeInteger}
    end
    obj_num = [obj.Num];
    num_index = zeros(size(Num));
    if ~isempty(Num)
        for i=1:length(Num)
            if Num(i)~=0
                index = find(obj_num==Num(i));
                if ~isempty(index)
                    num_index(i) = index(1);
                end
            end
        end
    end
end