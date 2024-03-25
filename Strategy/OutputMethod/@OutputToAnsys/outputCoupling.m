function output_str = outputCoupling(obj,fileName)
    arguments
        obj
        fileName = 'defCoupling.mac'
    end
    coupling_list = obj.OutputObj.CouplingList;
    % 输出的APDL字符串
    output_str = '';
    for i=1:length(coupling_list)
        coupling = coupling_list{i};
        count_slave_point = length(coupling.SlavePoint);
        count_command = floor(count_slave_point/16)+1;
        count_mod = mod(count_slave_point,16);
        cp_command = sprintf('!%s \n',coupling.Name);% 注释
            [defNode_cell,undefNode_cell] = findNodeByKeyPoint([coupling.MasterPoint,coupling.SlavePoint]);
            cp_command = [cp_command,strjoin(defNode_cell,'\n'),'\n','allsel \n'];
        for j=1:length(coupling.DoF)
            for k=1:count_command
                cp_command = [cp_command,sprintf('cp,Next,%s,Node1',char(coupling.DoF(j)))];
                for m=1:count_mod
                    cp_command = strcat(cp_command,sprintf(',Node%d',m+1));
                end
                cp_command = [cp_command,'\n'];
            end
            
        end
        cp_command = [cp_command,strjoin(undefNode_cell,' $ '),newline,newline];
        output_str = [output_str,cp_command];
    end
    % 输出到defCoupling.mac
    obj.outputAPDL(output_str,fileName,'w')
end
function [defNode_cell,undefNode_cell]= findNodeByKeyPoint(point)
    % 输入:Point对象数组
    % 输出:由Ansys中根据XYZ坐标寻找Node的命令：Num_node = node(x,y,z)来寻找点的字符串Cell
    defNode_cell = cell(1,length(point));
    undefNode_cell = cell(1,length(point));
    for i=1:length(point)
        defNode_cell{i} = sprintf(['ksel,s,kp,,%d ',...
                                   '$ nslk,s ',...
                                   '$ *get,Node%d,node,,num,min'],point(i).Num,i);
        undefNode_cell{i} = sprintf('Node%d =',i);
    end
end