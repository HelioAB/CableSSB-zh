function [coupling_list,index,coupling_MasterPoint_list,coupling_SlavePoint_list] = findCouplingByStructure(obj,StructureList)
    if isa(StructureList,'Structure')
        iscell = 0;
    elseif isa(StructureList,'cell')
        iscell = 1;
    else
        error('输入的StructureList必须为Structure对象数组或cell')
    end
    CouplingtList = obj.CouplingList;
    len_structure = length(StructureList);
    coupling_MasterPoint_list = cell(1,len_structure);
    coupling_SlavePoint_list = cell(1,len_structure);
    coupling_list = cell(1,len_structure);
    index = false(1,length(CouplingtList));
    for i=1:length(CouplingtList)
        coupling = CouplingtList{i};
        coupling_master_point = coupling.MasterPoint;
        for j=1:length(coupling_master_point)
            coupling_point_j = coupling_master_point(j);
            for k=1:len_structure
                if iscell
                    structure = StructureList{k};
                else
                    structure = StructureList(k);
                end
                points = structure.Point;
                % 如果Constraint对象的某个Point对象在某个Structure对象中存在，就说明这个Structure对象和这个Constraint对象有关
                % 否则constraint_list存储空值
                if any(coupling_point_j==points) 
                    coupling_MasterPoint_list{k} = [coupling_MasterPoint_list{k},coupling];
                    index(i) = true;
                end
            end
        end
        coupling_slave_point = coupling.SlavePoint;
        for j=1:length(coupling_slave_point)
            coupling_point_j = coupling_slave_point(j);
            for k=1:len_structure
                if iscell
                    structure = StructureList{k};
                else
                    structure = StructureList(k);
                end
                points = structure.Point;
                % 如果Constraint对象的某个Point对象在某个Structure对象中存在，就说明这个Structure对象和这个Constraint对象有关
                % 否则constraint_list存储空值
                if any(coupling_point_j==points) 
                    coupling_SlavePoint_list{k} = [coupling_SlavePoint_list{k},coupling];
                    index(i) = true;
                end
            end
        end
    end
    for i=1:len_structure
        coupling_list{i} = [coupling_MasterPoint_list{i},coupling_SlavePoint_list{i}];
    end
end