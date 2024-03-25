function output_str = outputMaterial(obj,fileName)
    arguments
        obj
        fileName = 'defMaterial.mac'
    end
    material_list = obj.OutputObj.MaterialList;
    unique_material_list = uniqueCell(material_list);
    len = length(unique_material_list);

    % 输出的APDL字符串
    output_str = '';
    for i=1:len
        % 第i个Material
        material = unique_material_list{i};
        structure = obj.OutputObj.findStructureByInfo(material);

        if isempty(material.Num)
            num = i;
            material.Num = i;
        else
            num = material.Num;
        end

        material_name = lower(material.Name);

        structure_name_cell = cellfun(@(obj) obj.Name,structure,'UniformOutput',false); % 获取使用了该Material的所有Structure对象的Name属性
        structure_name = char(join(structure_name_cell,', '));
        
        material_data = material.MaterialData.outputToAnsys();
        material_data_name = fieldnames(material_data);

        % 注释行1
        output_str = [output_str,sprintf(['! 材料名称: %s \n' ...
                                          '! 作用于以下Structure: %s'],material_name,structure_name),newline];

        % 循环输出Material对象的所有属性
        for j=1:length(material_data_name)
            % 第i个Material的第j个参数
            material_data_value = material_data.(material_data_name{j});
            output_str = [output_str, ...
                          sprintf('mp,%s,%d,%E \n',material_data_name{j},num,material_data_value)];
        end
        % 一种材料结束定义
        output_str = [output_str,newline];
    end
    % 输出到defMaterial.mac
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