function NaN_Node = computeDisplacement(obj)
    % 以下代码已经过运行时间优化
    Global_Displacement = obj.StiffnessMatrix\obj.RHS;
    if ~isfield(obj.TempResult,'computingDisplacement')
        Node2DoFEquation = obj.Maps.Node2DoFEquation;
        Num2Node = obj.Maps.Node;
        Nodes = keys(Node2DoFEquation);
        NaN_Node = [];
        InfoCell = cell(3,length(Nodes));
        for i=1:length(Nodes)
            num_node = Nodes{i};
            node = Num2Node(num_node);
            index_NaNDoF = false(1,6);
            dof = Node2DoFEquation(num_node);
            index_NodeDoF = [];
            index_Row = [];
            for j=1:6
                row_equation = dof(j);
                if ~row_equation % 在总刚中被消去的行
                    index_NaNDoF(j) = true;
                    continue
                else
                    index_NodeDoF = [index_NodeDoF,j];
                    index_Row = [index_Row,row_equation];
                end
                node.Displacement_GlobalCoord(j) = Global_Displacement(row_equation);
            end
            if any(index_NaNDoF)
                NaN_Node = [NaN_Node,node];
            end
            InfoCell{1,i} = node;
            InfoCell{2,i} = index_NodeDoF;
            InfoCell{3,i} = index_Row;
        end
        obj.TempResult.computingDisplacement = InfoCell;
    else
        InfoCell = obj.TempResult.computingDisplacement;
        for i=1:length(InfoCell)
            node = InfoCell{1,i};
            index_NodeDoF = InfoCell{2,i};
            index_Row = InfoCell{3,i};
            node.Displacement_GlobalCoord(index_NodeDoF) = Global_Displacement(index_Row);
        end
    end
end