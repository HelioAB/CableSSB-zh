function output_str = outputKeyPoint(obj,fileName,Map_OutputedPoint,bool_outputCM)
    arguments
        obj
        fileName = 'defKeyPoint.mac'
        Map_OutputedPoint = containers.Map('KeyType','double','ValueType','any'); % 存储已经输出过的Point
        bool_outputCM = true
    end
    structure_list = obj.OutputObj.StructureList;
    % 输出的APDL字符串
    if bool_outputCM
        output_str = ['ksel,none \n' ...
                      'cm,kp_selected,kp',newline,newline];
    else
        output_str = ['allsel',newline];
    end
    for i=1:length(structure_list)
        structure = structure_list{i};
        ij_points = structure.Point;
        k_points = [structure.Line.KPoint];
        if ~isempty(k_points)
            k_points = k_points.unique();
        else
            k_points = [];
        end
        key_points = [ij_points,k_points];
        output_str = [output_str,sprintf(['! ',structure.Name,' \n'])];
        for j = 1:length(key_points)
            if isKey(Map_OutputedPoint,key_points(j).Num)
                continue
            else
                output_str = [output_str,sprintf('k,%d,%f,%f,%f \n',key_points(j).Num,key_points(j).X,key_points(j).Y,key_points(j).Z)];
                Map_OutputedPoint(key_points(j).Num) = key_points(j);
            end
        end
        if bool_outputCM
            output_str = [output_str,['ksel,all \n' ...
                                          'cmsel,u,kp_selected \n' ...2
                                          'cm,',['KeyPoint_',structure.Name],',kp \n' ...
                                          'ksel,all \n' ...
                                          'cm,kp_selected,kp \n' ...
                                          'allsel \n'],newline];
        end
    end
    % 输出到defKeyPoint.mac
    obj.outputAPDL(output_str,fileName,'w')
    obj.OutputObj.Params.Map_OutputedPoint = Map_OutputedPoint;
end