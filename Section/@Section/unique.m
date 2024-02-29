function [uni_obj,index_input2uni,index_uni2input] = unique(obj)
    len = length(obj);
    repeat_flag = false(1,len);
    uni_obj = [];
    index_input2uni = [];
    index_uni2input = [1:len];
    for i=1:len
        if repeat_flag(i)
            continue
        end
        current_obj = obj(i);
        uni_obj = [uni_obj,current_obj];
        index_input2uni = [index_input2uni,i];
        index_uni2input(i) = length(uni_obj);
        if i<len
            for j=i+1:len
                compare_obj = obj(j);
                if current_obj == compare_obj
                    repeat_flag(j) = true;
                    index_uni2input(j) = length(uni_obj);
                end
            end
        end
    end
end