function [c,ceq] = test_solveHangerTopCoord_NonlinearControl(hanger,cable,P_girder_z,P_cable)
    len = length(P_cable);
    P_cable_x_k = -P_cable(1:len/3);
    P_cable_y_k = -P_cable(len/3+1:2*len/3);
    P_cable_z_k = -P_cable(2*len/3+1:len);
    
     % 等式约束：要满足吊索的上下端拉力,ceq=0
    [P_cable_x_kk,P_cable_y_kk,P_cable_z_kk] = hanger.getP(P_girder_z);
    ceq = [P_cable_x_kk-P_cable_x_k,P_cable_y_kk-P_cable_y_k,P_cable_z_kk-P_cable_z_k];

%     assignin("base","P_cable_x_k1_Con",P_cable_x_k1)
    assignin("base","P_cable_y_kk_Con",P_cable_y_kk)
    assignin("base","P_cable_y_k_Con",P_cable_y_k)
%     assignin("base","P_cable_z_k1_Con",P_cable_z_k1)

    % 不等式约束：缆索y方向的分力要在合适的范围内,c<=0
    cable_PointA = cable.PointA;
    cable_PointB = cable.PointB;
    Coord_MidPoint = (cable_PointA.Coord + cable_PointB.Coord)/2;
    GirderPoints = hanger.findGirderPoint;
    Coord_GirderPoint = GirderPoints.Coord;
    Y_GirderPoint = Coord_GirderPoint(:,2)';
    delta_Y = Y_GirderPoint - Coord_MidPoint(2);
    c = -sign(delta_Y.*P_cable_y_k);

    assignin("base","delta_Y",delta_Y)
%     assignin("base","P_cable_x_k1_Con",P_cable_x_k1)
%     assignin("base","P_cable_y_k1_Con",P_cable_y_k1)
%     assignin("base","P_cable_z_k1_Con",P_cable_z_k1)
end