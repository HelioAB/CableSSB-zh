function output_str = outputLine(obj,fileName,num_start,Map_MatlabLine2AnsysLine,Map_AnsysLine2MatlabLine,bool_outputCM)
    arguments
        obj
        fileName = 'defLine.mac'
        num_start = 1
        Map_MatlabLine2AnsysLine = containers.Map('KeyType','double','ValueType','any');
        Map_AnsysLine2MatlabLine = containers.Map('KeyType','double','ValueType','any');
        bool_outputCM = true
    end
    % 输出：
    %   Map_MatlabLine2AnsysLine: 一个从Matlab中Line的编号映射到Ansys中的Line编号
    structure_list = obj.OutputObj.StructureList;
    % 输出的APDL字符串
    num_line = num_start;
    if bool_outputCM
        output_str = ['lsel,none',newline,...
                      'cm,l_selected,line',newline,...
                      sprintf('numstr,line,%d',num_start),newline,newline];
    else
        output_str = ['allsel',newline];
    end
    for i=1:length(structure_list)
        structure = structure_list{i};
        line = structure.NewLine;
        
        output_str = [output_str,sprintf(['! ',structure.Name,' \n'])];
        for j = 1:length(line)
            output_str = [output_str,sprintf(['l,%d,%d' ...
                                              ' ! Matlab中Line对象编号: %d; Ansys中line编号%d \n'],line(j).IPoint.Num,line(j).JPoint.Num,line(j).Num,num_line)];
            Map_AnsysLine2MatlabLine(num_line) = line(j);
            Map_MatlabLine2AnsysLine(line(j).Num) = num_line;
            num_line = num_line + 1;
        end
        if bool_outputCM
            output_str = [output_str,['lsel,all \n' ...
                                          'cmsel,u,l_selected \n' ...
                                          'cm,',['Line_',structure.Name],',line \n' ...
                                          'lsel,all \n' ...
                                          'cm,l_selected,line \n' ...
                                          'allsel \n'],newline];
        end
    end
    % 输出到defLine.mac
    obj.outputAPDL(output_str,fileName,'w')
    obj.OutputObj.Params.Map_MatlabLine2AnsysLine = Map_MatlabLine2AnsysLine;
    obj.OutputObj.Params.Map_AnsysLine2MatlabLine = Map_AnsysLine2MatlabLine;
end

