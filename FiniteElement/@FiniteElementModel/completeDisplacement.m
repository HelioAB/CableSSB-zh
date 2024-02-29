function NaN_Node = completeDisplacement(obj)
    % 补全Constraint和Coupling消去的位移
    % 获得相关数据
    bridge = obj.BridgeModel;
    constraint_list = bridge.ConstraintList;
    coupling_list = bridge.CouplingList;
    Point2Node = obj.Maps.Point2Node;
    Map_Node = obj.Maps.Node;
    % 补全Constraint导致的位移消去
    for i=1:length(constraint_list)
        constraint = constraint_list{i};
        constraint_point = constraint.Point;
        constraint_dof = constraint.DoF;
        constraint_value = constraint.Value;
        index_dof = constraint_dof.getIndex;
        for j=1:length(constraint_point)
            constraint_point_j = constraint_point(j);
            constraint_node = Map_Node(Point2Node(constraint_point_j.Num));
            for k=1:length(constraint_dof)
                % constraint_node使用指定的constraint_value
                constraint_node.Displacement_GlobalCoord(index_dof(k)) = constraint_value(k);
            end
        end
    end
    % 补全Coupling导致的位移消去
    for i=1:length(coupling_list)
        coupling = coupling_list{i};
        master_point = coupling.MasterPoint;
        master_node = Map_Node(Point2Node(master_point.Num));
        slave_point = coupling.SlavePoint;
        coupling_dof = coupling.DoF;
        index_dof = coupling_dof.getIndex;
        for j=1:length(slave_point)
            slave_point_j = slave_point(j);
            slave_node_j = Map_Node(Point2Node(slave_point_j.Num));
            for k=1:length(coupling_dof)
                % slave_node使用master_node的位移值
                slave_node_j.Displacement_GlobalCoord(index_dof(k)) = master_node.Displacement_GlobalCoord(index_dof(k));
            end
        end
    end
    % 检查还有没补全的位移
    NaN_Node = obj.checkNaNDisplacement;
end