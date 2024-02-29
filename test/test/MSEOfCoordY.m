function MSE = MSEOfCoordY(DeltaCoord,hanger,cable,P_girder_z)
    % CableCoord(F_{hanger}(CableCoord_0 + DeltaCoord)) - (CableCoord_0 + DeltaCoord) = 0
    % cable必须是：仅使用竖向力进行找形的Cable对象

    % 1. 获得复制体
    cable_cloned = cable.clone;
    girder_point = hanger.findGirderPoint;
    GirderPoint_hanger = girder_point.clone;
    cable_point = hanger.findCablePoint;
    CablePoint_hanger = cable_point.clone;
    sorted_CablePoint_hanger = CablePoint_hanger.sort('X');
    hanger_cloned = Hanger(GirderPoint_hanger,CablePoint_hanger,hanger.Section,hanger.Material,"JStructure",cable_cloned);

    % 2. 获得变化后的吊点坐标值 CableCoord_0 + DeltaCoord
    len = length(DeltaCoord);
    if len ~= length(sorted_CablePoint_hanger)
        error('优化变量 DeltaCoord 的向量长度应为 3*吊索数')
    end
    sorted_CablePoint_hanger.translate([zeros(len,1),DeltaCoord',zeros(len,1)]);

    % 3. 计算吊索力 F_{hanger}(CableCoord_0 + DeltaCoord)
    [P_cable_x,P_cable_y,P_cable_z] = hanger_cloned.getP(P_girder_z); % P_cable均为吊索受力，作用在主缆上时，需要反号

    % 4. 作用吊索力之后的主缆线形 CableCoord(F_{hanger}(CableCoord_0 + DeltaCoord))
    [P_x,P_y,P_z] = cable_cloned.P(cable.Params.Index_Hanger,-P_cable_x,-P_cable_y,-P_cable_z);
    cable_cloned.findShape(P_x,P_y,P_z);

    % 5. 均方误差 MSE CableCoord(F_{hanger}(CableCoord_0 + DeltaCoord)) - (CableCoord_0 + DeltaCoord) = 0
    index_hanger = [false,cable_cloned.Params.Index_Hanger,false];
    CablePoint_cable = cable_cloned.Point(index_hanger); % 吊索吊点
    sorted_CablePoint_cable = CablePoint_cable.sort('X');
    ErrorCoord = sorted_CablePoint_cable.Coord - sorted_CablePoint_hanger.Coord;
    MSE = sum(ErrorCoord(:,2).^2)/len;
end