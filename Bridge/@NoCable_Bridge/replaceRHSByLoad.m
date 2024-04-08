function replaceRHSByLoad(obj)
    [AppliedPoints,XPointForce,YPointForce,ZPointForce] = obj.getConcentratedForcecInfo;% 获得obj.LoadList的所有信息
    num_points = [AppliedPoints.Num];

    Point2Node = obj.FiniteElementModel.Maps.Point2Node;
    Node2DoFEquation = obj.FiniteElementModel.Maps.Node2DoFEquation;
    RHS = obj.FiniteElementModel.RHS;
    
    assignin('base',"AppliedPoints",AppliedPoints)
    assignin('base',"num_points",num_points)
    assignin('base',"Point2Node",Point2Node)
    for i=1:length(num_points)
        num_nodes = Point2Node(num_points(i));
        row_equation = Node2DoFEquation(num_nodes);
        if row_equation(1)==0
        else
            RHS(row_equation(1)) = XPointForce(i);
        end
        if row_equation(2)==0
        else
            RHS(row_equation(2)) = YPointForce(i);
        end
        if row_equation(3)==0
        else
            RHS(row_equation(3)) = ZPointForce(i);
        end
    end
    obj.FiniteElementModel.RHS = RHS;
end