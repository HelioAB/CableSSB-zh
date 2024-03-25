function output_str = outputElementType(obj,fileName)
    arguments
        obj
        fileName = 'defElementType.mac'
    end
    element_type_list = obj.OutputObj.ElementTypeList;
    unique_element_type_list = uniqueCell(element_type_list);
    len = length(unique_element_type_list);

    % 输出的APDL字符串
    output_str = '';
    for i=1:len
        % 第i个ElementType
        element_type = unique_element_type_list{i};
        structure = obj.OutputObj.findStructureByInfo(element_type);

        % 如果定义了ElementType.Num，就使用定义的Num；如果没有，就和现在编号
        if isempty(element_type.Num)
            num = i;
            element_type.Num = i;
        else
            num = element_type.Num;
        end
        % Beam或Link类型的单元有不同的输出方式
        element_type_class = lower(class(element_type));
        structure_name_cell = cellfun(@(obj) obj.Name,structure,'UniformOutput',false); % 获取使用了该ElementType的所有Structure对象的Name属性
        structure_name = char(join(structure_name_cell,', '));
        output_str = [output_str,sprintf(['! 单元名称：%s \n' ...
                                          '! 作用于以下Structure: %s'],element_type.Name,structure_name),newline];
        % 单元定义
        output_str = [output_str,element_type.outputElementType(num),newline,newline];
    end
    % 输出到defElementType.mac
    obj.outputAPDL(output_str,fileName,'w')
end
function [unique_cell,index] = uniqueCell(cell)
    % 如果一个Cell中装了有重复的对象，本函数将重复的对象去除
    % p1 = Point(1,1,1,1);
    % p2 = Point(2,2,2,2);
    % cell = {[p1,p1,p1],[p2,p1,p2],p1,p2,p1,p1,p1,[p1,p1,p1],[p1,p1,p1,p1],[p2,p1,p2]};
    arguments
        cell (1,:)
    end
    index = true(1,length(cell));
    for i=1:length(cell)
        if ~index(i)
            continue
        end
        for j=i:length(cell)
            if length(cell{i}) ~= length(cell{j}) % 当cell{i}与cell{j}长度不同时，无法直接使用cell{i}==cell{j}比较两者
            elseif cell{i}==cell{j} & i~=j
                index(j) = false;
            end
        end
    end
    unique_cell = cell(index);
end