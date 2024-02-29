function [constraint_list,index] = findConstraintByStructure(obj,StructureList)
    if isa(StructureList,'Structure')
        iscell = 0;
    elseif isa(StructureList,'cell')
        iscell = 1;
    else
        error('输入的StructureList必须为Structure对象数组或cell')
    end
    ConstraintList = obj.ConstraintList;
    len_structure = length(StructureList);
    constraint_list = cell(1,len_structure);
    index = false(1,length(ConstraintList));
    for i=1:length(ConstraintList)
        constraint = ConstraintList{i};
        constraint_point = constraint.Point;
        for j=1:length(constraint_point)
            constraint_point_j = constraint_point(j);
            for k=1:len_structure
                if iscell
                    structure = StructureList{k};
                else
                    structure = StructureList(k);
                end
                points = structure.Point;
                % 如果Constraint对象的某个Point对象在某个Structure对象中存在，就说明这个Structure对象和这个Constraint对象有关
                % 否则constraint_list存储空值
                if any(constraint_point_j==points) 
                    constraint_list{k} = [constraint_list{k},constraint];
                    index(i) = true;
                end
            end
        end
    end
end