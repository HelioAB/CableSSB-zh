function output_str = outputSection(obj,fileName)
    arguments
        obj
        fileName = 'defSection.mac'
    end
    section_list = obj.OutputObj.SectionList;
    element_type_list = obj.OutputObj.ElementTypeList;

    % 如果是Link*单元或Beam4单元，就跳过，交给outputReal来输出
    index_output_section = true(1,length(section_list));
    for i=1:length(element_type_list)
        element_type_name = element_type_list{i}.Name;
        if strncmpi(element_type_name,'Link',4) || strcmpi(element_type_name,'beam4')
            index_output_section(i) = false;
        end
    end
    output_section = section_list(index_output_section);

    % 去除出现多次的Section对象，仅输出出现过一次的Section对象
    unique_section_list = uniqueCell(output_section);
    unique_section = cell2obj(unique_section_list);
    len = length(unique_section);

    % 输出的APDL字符串
    output_str = '';
    for i=1:len
        % 第i个Section对象数组
        section = unique_section(i);
        % 注释行1
        output_str = [output_str,sprintf('! 截面名称: %s',section.Name),...
                                 section.SectionData.OutputToAnsys(section.Num),newline];
        % 一种截面结束定义
        output_str = [output_str,'!-------------------------',newline];
    end
    % 输出到defSection.mac
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
function obj_array = cell2obj(cell)
    % 转换后的对象数组必须是相同的类
    len = length(cell);
    obj_array = [];
    for i=1:len
        obj_array = [obj_array,cell{i}];
    end
end