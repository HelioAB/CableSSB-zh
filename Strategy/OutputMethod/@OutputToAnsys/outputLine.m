function output_str = outputLine(obj)
    % 输出：
    %   Map_MatlabLine2AnsysLine: 一个从Matlab中Line的编号映射到Ansys中的Line编号
    structure_list = obj.OutputObj.StructureList;
    Map_MatlabLine2AnsysLine = containers.Map('KeyType','double','ValueType','any');
    Map_AnsysLine2MatlabLine = containers.Map('KeyType','double','ValueType','any');
    % 输出的APDL字符串
    output_str = ['lsel,none \n' ...
                  'cm,l_selected,line',newline,newline];
    count_line = 0;
    for i=1:length(structure_list)
        structure = structure_list{i};
        line = structure.NewLine;
        
        output_str = [output_str,sprintf(['! ',structure.Name,' \n'])];
        for j = 1:length(line)
            count_line = count_line + 1;
            output_str = [output_str,sprintf(['l,%d,%d' ...
                                              ' ! Matlab中Line对象编号: %d; Ansys中line编号%d \n'],line(j).IPoint.Num,line(j).JPoint.Num,line(j).Num,count_line)];
            Map_AnsysLine2MatlabLine(count_line) = line(j);
            Map_MatlabLine2AnsysLine(line(j).Num) = count_line;
        end
        output_str = [output_str,['lsel,all \n' ...
                                      'cmsel,u,l_selected \n' ...
                                      'cm,',['Line_',structure.Name],',line \n' ...
                                      'lsel,all \n' ...
                                      'cm,l_selected,line \n' ...
                                      'allsel \n'],newline];
    end
    % 输出到defLine.mac
    obj.outputAPDL(output_str,'defLine.mac','w')
    obj.OutputObj.Params.Map_MatlabLine2AnsysLine = Map_MatlabLine2AnsysLine;
    obj.OutputObj.Params.Map_AnsysLine2MatlabLine = Map_AnsysLine2MatlabLine;
end

