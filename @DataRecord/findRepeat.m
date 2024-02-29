function [rep_num,rep_obj,rep_index] = findRepeat(obj)
    rep_num = [];
    rep_obj = {};
    rep_index = {};
    if ~isempty(obj)
        num = [obj.Num];
        uni_num = unique(num);
        len = length(uni_num);
        for i=1:len
            index = uni_num(i) == num;
            if sum(index)>1 % 出现多于1次的
                rep_num(end+1) = uni_num(i);
                rep_obj{end+1} = obj(index);
                rep_index{end+1} = index;
            end
        end
    end
end