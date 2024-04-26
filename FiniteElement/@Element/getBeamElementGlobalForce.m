function [ANodes,BNodes,InternalForce_A,InternalForce_B] = getBeamElementGlobalForce(obj,type_elems,type_force)
    arguments
        obj
        type_elems {mustBeMember(type_elems,{'Girder','Tower'})}
        type_force {mustBeMember(type_force,{'Fx','My'})}
    end
    % 该函数是用来输出内力值，内力值在图中的大小需要依赖该函数
    if strcmp(type_elems,'Girder')
        direction_sort = 'X';        
    elseif strcmp(type_elems,'Tower')
        direction_sort = 'Z';
        if strcmp(type_force,'Fx')
            error('暂时不支持提取Tower对象的Fx')
        end
    end
    sorted_elems = obj.sortByCenterPoint(direction_sort);
    % 获取内力结果
    switch type_force
        case 'Fx'
            Force_Force_LocalCoord = [sorted_elems.Force_LocalCoord];
            InternalForce_i = Force_Force_LocalCoord(1,:);
            InternalForce_j = Force_Force_LocalCoord(7,:);
        case 'My'
            Force_Force_LocalCoord = [sorted_elems.Force_LocalCoord];
            Myi = Force_Force_LocalCoord(5,:);
            Myj = Force_Force_LocalCoord(11,:);
            Mzi = Force_Force_LocalCoord(6,:);
            Mzj = Force_Force_LocalCoord(12,:);
            [~,Comp_y,Comp_z] = sorted_elems.getLocalCoordSystemComponent([0,1,0]);
            InternalForce_i = Myi.*Comp_y' + Mzi.*Comp_z';
            InternalForce_j = Myj.*Comp_y' + Mzj.*Comp_z';
    end
    % 根据实际位置关系，将内力进行排序
    [index_INodeSmaller,index_JNodeSmaller,index_IJNodeSame] = sorted_elems.ifINodeSmaller(direction_sort);
    INodes = [sorted_elems.INode];
    JNodes = [sorted_elems.JNode];
    ANodes(1,length(sorted_elems)) = Node(); % 坐标较小的一端
    BNodes(1,length(sorted_elems)) = Node(); % 坐标较大的一端
    InternalForce_A = zeros(1,length(sorted_elems));
    InternalForce_B = zeros(1,length(sorted_elems));
    for i=1:length(sorted_elems)
        if index_IJNodeSame(i)            
            ANodes(i) = INodes(i);
            BNodes(i) = JNodes(i);
        elseif index_INodeSmaller(i)
            ANodes(i) = INodes(i);
            BNodes(i) = JNodes(i);
            InternalForce_A(i) = InternalForce_i(i);
            InternalForce_B(i) = InternalForce_j(i);
        elseif index_JNodeSmaller(i)
            ANodes(i) = JNodes(i);
            BNodes(i) = INodes(i);
            InternalForce_A(i) = InternalForce_j(i);
            InternalForce_B(i) = InternalForce_i(i);
        end
    end
    % 将Tower对象的My进行求和
    if strcmp(type_elems,'Tower') && strcmp(type_force,'My')
        % 相同
        ANodes_temp = ANodes(~index_IJNodeSame);
        BNodes_temp = BNodes(~index_IJNodeSame);
        InternalForce_A_temp = InternalForce_A(~index_IJNodeSame);
        InternalForce_B_temp = InternalForce_B(~index_IJNodeSame);
        % 分叉
        Z_ANodes = [ANodes_temp.Z];
        Z_BNodes = [BNodes_temp.Z];
        len = length(ANodes_temp);
        indexcell = cell(1,len);
        flag = false(1,len);
        for i=1:len
            if ~flag(i)
                condition = (Z_ANodes(i) == Z_ANodes) & (Z_BNodes(i) == Z_BNodes);
                indexcell{i} = condition;
                flag(condition) = true;
            end
        end
        flag_noskip = false(1,len);
        InternalForce_A = zeros(1,len);
        InternalForce_B = zeros(1,len);
        for i=1:len
            if ~isempty(indexcell{i})
                flag_noskip(i) = true;
                InternalForce_A(i) = sum(InternalForce_A_temp(indexcell{i}));
                InternalForce_B(i) = sum(InternalForce_B_temp(indexcell{i}));
            end
        end
        ANodes = ANodes_temp(flag_noskip);
        BNodes = BNodes_temp(flag_noskip);
        InternalForce_A = InternalForce_A(flag_noskip);
        InternalForce_B = InternalForce_B(flag_noskip);
    end
end