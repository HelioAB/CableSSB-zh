function output_str = outputKeyPoint(obj)
    structure_list = obj.OutputObj.StructureList;
    % 输出的APDL字符串
    output_str = ['ksel,none \n' ...
                  'cm,kp_selected,kp',newline,newline];
    Map_OutputedPoint = containers.Map('KeyType','double','ValueType','any'); % 存储已经输出过的Point
    for i=1:length(structure_list)
        structure = structure_list{i};
        key_point = structure.Point;
        output_str = [output_str,sprintf(['! ',structure.Name,' \n'])];
        for j = 1:length(key_point)
            if isKey(Map_OutputedPoint,key_point(j).Num)
                continue
            else
                output_str = [output_str,sprintf('k,%d,%f,%f,%f \n',key_point(j).Num,key_point(j).X,key_point(j).Y,key_point(j).Z)];
                Map_OutputedPoint(key_point(j).Num) = key_point(j);
            end
        end
        output_str = [output_str,['ksel,all \n' ...
                                      'cmsel,u,kp_selected \n' ...2
                                      'cm,',['KeyPoint_',structure.Name],',kp \n' ...
                                      'ksel,all \n' ...
                                      'cm,kp_selected,kp \n' ...
                                      'allsel \n'],newline];
    end
    % 输出到defKeyPoint.mac
    obj.outputAPDL(output_str,'defKeyPoint.mac','w')
end