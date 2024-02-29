function serialize(obj)
    % 将对象数组中混乱的Num排序成 规则的顺序，常用于导入的结构
    % 例如[obj.Num] == [1,2,3,10,1,5]
    [uni_obj,~,uni2obj_index] = obj.unique();
    num_uni = [uni_obj.Num]; % [uni_obj.Num] = [1,2,3,5,10]
    serial_num_uni = min(num_uni):min(num_uni)+length(num_uni)-1; % [serial_num_uni.Num] == [1,2,3,4,5]
    num_ChangeTo = serial_num_uni(uni2obj_index); % [num_ChangeTo.Num] = [1,2,3,5,1,4]
    obj.edit('Num',num_ChangeTo);
end