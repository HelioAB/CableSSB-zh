function output_str = outputLineMesh(obj,fileName,num_start,Map_MatlabLine2AnsysElem,Map_AnsysElem2MatlabLine,bool_outputCM)
    arguments
        obj
        fileName = 'defLineMesh.mac'
        num_start = 1
        Map_MatlabLine2AnsysElem = containers.Map('KeyType','double','ValueType','any');
        Map_AnsysElem2MatlabLine = containers.Map('KeyType','double','ValueType','any');
        bool_outputCM = true
    end
    structure_list = obj.OutputObj.StructureList;
    Map_MatlabLine2AnsysLine = obj.OutputObj.Params.Map_MatlabLine2AnsysLine;
    % 输出的APDL字符串
    if bool_outputCM
        output_str = ['allsel',newline,...
                      'esel,none \n',newline,...
                      'cm,e_selected,elem',newline,...
                      sprintf('numstr,elem,%d',num_start),newline,newline];
    else
        output_str = ['allsel',newline];
    end
    count_elem = num_start;
    for i=1:length(structure_list)
        structure = structure_list{i};
        division = structure.ElementDivisionNum;
        output_str = [output_str,sprintf('! %s',structure.Name),newline];
        line = structure.Line;
        for j=1:length(line)
            num_ansys_line = Map_MatlabLine2AnsysLine(line(j).Num);
            output_str = [output_str,sprintf(['lesize,%d,,,%d $ lmesh,%d'],num_ansys_line,division,num_ansys_line),newline];
            Map_MatlabLine2AnsysElem(line(j).Num) = count_elem:count_elem+division-1;
            for k=1:division
                Map_AnsysElem2MatlabLine(count_elem+k-1) = line(j);
            end
            count_elem = count_elem + division;
        end
        if bool_outputCM
            output_str = [output_str,['esel,all \n' ...
                                      'cmsel,u,e_selected \n' ...
                                      'cm,',['Elem_',structure.Name],',elem \n' ...
                                      'esel,all \n' ...
                                      'cm,e_selected,elem \n' ...
                                      'allsel'],newline,newline];
        end
    end
    % 输出到defLineMesh.mac
    obj.outputAPDL(output_str,fileName,'w')
    obj.OutputObj.Params.Map_MatlabLine2AnsysElem = Map_MatlabLine2AnsysElem;
    obj.OutputObj.Params.Map_AnsysElem2MatlabLine = Map_AnsysElem2MatlabLine;
end