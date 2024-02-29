function NaN_Node = checkNaNDisplacement(obj,NodeArray)
    arguments
        obj
        NodeArray = obj.Node
    end
    NaN_Node = [];
    for i=1:length(NodeArray)
        node = NodeArray(i);
        dis = node.Displacement_GlobalCoord;
        index_nan = isnan(dis);
        if any(index_nan)
            NaN_Node = [NaN_Node,node];
        end
    end
end