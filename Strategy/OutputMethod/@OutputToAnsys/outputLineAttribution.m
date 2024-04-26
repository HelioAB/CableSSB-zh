function output_str = outputLineAttribution(obj,fileName)
    arguments
        obj
        fileName = 'defLineAttribution.mac'
    end
    % Matlab中line编号转换到Ansys中的line编号
    Map_convert = obj.OutputObj.Params.Map_MatlabLine2AnsysLine; % 因为Ansys中不能直接定义line的编号，所以需要一个Matlab中Line编号到Ansys中Line编号的映射
    % 分离Link单元、Beam4单元、其他单元
    element_type_list = obj.OutputObj.ElementTypeList;
    index_output_link = false(1,length(element_type_list));
    index_output_beam4 = false(1,length(element_type_list));
    index_output_other = false(1,length(element_type_list));
    for i=1:length(element_type_list)
        element_type_name = class(element_type_list{i});
        if strncmpi(element_type_name,'Link',4)
            index_output_link(i) = true;
        elseif strcmpi(element_type_name,'Beam4')
            index_output_beam4(i) = true;
        else
            index_output_other(i) = true;
        end
    end
    link_structure_list = obj.OutputObj.StructureList(index_output_link);
    beam4_structure_list = obj.OutputObj.StructureList(index_output_beam4);
    other_structure_list = obj.OutputObj.StructureList(index_output_other);
    len_link = length(link_structure_list);
    len_beam4 = length(beam4_structure_list);
    len_other = length(other_structure_list);
    % 生成APDL字符串
    output_str = '';
    for i=1:len_link
        structure = link_structure_list{i};
        line = structure.Line;
        output_str = [output_str,sprintf(['! ',structure.Name]),newline];
        for j=1:length(line)
            output_str = [output_str,sprintf('lsel,s,,,%d $ latt,%d,%d,%d',Map_convert(line(j).Num),structure.Material.Num,line(j).Num,structure.ElementType.Num),newline];
        end
        output_str = [output_str,newline];
    end
    for i=1:len_beam4
        structure = beam4_structure_list{i};
        line = structure.Line;
        output_str = [output_str,sprintf(['! ',structure.Name]),newline];
        for j=1:length(line)
            kpoint = line(j).KPoint;
            if isempty(kpoint)
                num_kpoint = '';
            else
                num_kpoint = num2str(kpoint.Num); % 因为Ansys中KeyPoint是可以定义编号的（与Line不同），所以可以直接使用Matlab中的KeyPoint的编号
            end
            output_str = [output_str,sprintf('lsel,s,,,%d $ latt,%d,%d,%d,,%s \n',Map_convert(line(j).Num),structure.Material.Num,Map_convert(line(j).Num),structure.ElementType.Num,num_kpoint)];
        end
        output_str = [output_str,newline];

    end
    for i=1:len_other
        structure = other_structure_list{i};
        line = structure.Line;
        output_str = [output_str,sprintf(['! ',structure.Name]),newline];
        for j=1:length(line)
            kpoint = line(j).KPoint;
            if isempty(kpoint)
                num_kpoint = '';
            else
                num_kpoint = num2str(kpoint.Num);
            end
            output_str = [output_str,sprintf('lsel,s,,,%d $ latt,%d,,%d,,%s,,%d \n',Map_convert(line(j).Num),structure.Material.Num,structure.ElementType.Num,num_kpoint,structure.Section(j).Num)];
        end
        output_str = [output_str,newline];
    end
    % 输出output_str
    obj.outputAPDL(output_str,fileName,'w')
end