function Load_CableForce = replaceCableByForce(obj,X,Pz,replaceMethod)
    arguments
        obj
        X
        Pz
        replaceMethod {mustBeMember(replaceMethod,{'Estimating','ShapeFinding'})} = 'ShapeFinding'
    end
    if obj.SelfAnchored
        % 寻找点
        cables = obj.ReplacedCable;
        if ~isempty(cables)
            PointAs(1,length(cables)) = Point();
            PointBs(1,length(cables)) = Point();
            for i=1:length(cables)
                cable = cables(i);
                PointAs(i) = cable.PointA;
                PointBs(i) = cable.PointB;
            end
            X_PointAs = [PointAs.X];
            X_PointBs = [PointBs.X];
            X_PointA_total = min(X_PointAs);
            X_PointB_total = max(X_PointBs);
            index_sidespan_CableA = X_PointAs == X_PointA_total;
            index_sidespan_CableB = X_PointBs == X_PointB_total;
            girders = obj.findStructureByClass('Girder');
            for i=1:length(girders)
                girder = girders{i};
                Point_find = girder.Point.findPointByRange(X_PointA_total,[],[]);
                if ~isempty(Point_find)
                    PointA = Point_find;
                end
                Point_find = girder.Point.findPointByRange(X_PointB_total,[],[]);
                if ~isempty(Point_find)
                    PointB = Point_find;
                end
            end
    
            if strcmp(replaceMethod,'Estimating')
                [ForceA_Z,ForceB_Z] = getAnchorForce_ByEstimating(obj,X,Pz,index_sidespan_CableA,index_sidespan_CableB);
            elseif strcmp(replaceMethod,'ShapeFinding')
                [ForceA_Z,ForceB_Z] = getAnchorForce_ByShapeFinding(obj,X,Pz,index_sidespan_CableA,index_sidespan_CableB);
            end
            
            % 主缆锚碇力
            load_A_Z = ConcentratedForce(PointA,'Z',ForceA_Z);
            load_A_Z.Name = '主缆锚固力 1 Z方向';
    
            load_B_Z = ConcentratedForce(PointB,'Z',ForceB_Z);
            load_B_Z.Name = '主缆锚固力 2 Z方向';
    
            Load_CableForce = {load_A_Z,load_B_Z};
        else
            Load_CableForce = [];
        end
    else
        Load_CableForce = [];
    end

end
function [ForceA_Z,ForceB_Z] = getAnchorForce_ByEstimating(obj,X,Pz,index_sidespan_CableA,index_sidespan_CableB)
    Pz_Hanger = [];
    % 吊索拉力
    hangers = obj.ReplacedHanger;
    len_hanger = length(hangers);
    for i=1:len_hanger
        hanger = hangers(i);
        Pz_girder = obj.getGirderPz(hanger,X,Pz);
        [~,~,P_cable_z] = hanger.getP(Pz_girder);
        Pz_Hanger = [Pz_Hanger,P_cable_z];
    end
    % 
    cables = obj.ReplacedCable;
    cable_weight = zeros(1,length(cables));

    for i=1:length(cables)
        cable = cables(i);
        % 计算主缆的总重
        cable_weight(i) = sum(cable.Material.MaterialData.gamma .* cable.Section.Area .* cable.UnstressedLength);
    end
    index_mainspan_Cable = (~index_sidespan_CableA) & (~index_sidespan_CableB);
    ForceA_Z = (sum(cable_weight(index_mainspan_Cable))+sum(Pz_Hanger))/2 - sum(cable_weight(index_sidespan_CableA));
    ForceB_Z = (sum(cable_weight(index_mainspan_Cable))+sum(Pz_Hanger))/2 - sum(cable_weight(index_sidespan_CableB));
end
function [ForceA_Z,ForceB_Z] = getAnchorForce_ByShapeFinding(obj,X,Pz,index_sidespan_CableA,index_sidespan_CableB)
    cables = obj.ReplacedCable;
    index_mainspan_Cable = (~index_sidespan_CableA) & (~index_sidespan_CableB);
    mainspan_Cables = cables(index_mainspan_Cable);
    sidespan_CableAs = cables(index_sidespan_CableA);
    sidespan_CableBs = cables(index_sidespan_CableB);

    % 主跨主缆
    mainspan_cable = mainspan_Cables(1);
    % 主跨主缆找形
    hanger = mainspan_cable.findConnectStructureByClass('Hanger');
    P_girder_z = obj.getGirderPz(hanger,X,Pz);
    w = hanger.Material.MaterialData.gamma .* hanger.Section.Area; % 每延米自重
    P_w_k = -w.*hanger.getUnstressedLengthByForce(-P_girder_z);
    P_cable_z = abs(P_girder_z + P_w_k);
    [P_x,P_y,P_z] = mainspan_cable.P(mainspan_cable.Params.Index_Hanger,ones(1,length(P_cable_z)),ones(1,length(P_cable_z)),-P_cable_z);
    obj.Params.Params_ShapeFinding_MainSpanCable = mainspan_cable.Params;
    obj.Params.Params_ShapeFinding_MainSpanCable.Init_var = mainspan_cable.Result_ShapeFinding.x;
    obj.Params.Params_ShapeFinding_MainSpanCable.ObjectiveLimit = 1e-3;
    mainspan_cable.Params = obj.Params.Params_ShapeFinding_MainSpanCable;
    mainspan_cable.findShape(P_x,P_y,P_z);
    % 主跨主缆获取F_x
    F_x = mainspan_cable.Result_ShapeFinding.F_x;
    
    % 根据F_x计算边跨锚固点的力
    sidespan_CableA = sidespan_CableAs(1);
    hanger = sidespan_CableA.findConnectStructureByClass('Hanger');
    if ~isempty(hanger)
        P_girder_z = obj.getGirderPz(hanger,X,Pz);
        w = hanger.Material.MaterialData.gamma .* hanger.Section.Area; % 每延米自重
        P_w_k = -w.*hanger.getUnstressedLengthByForce(-P_girder_z);
        P_cable_z = abs(P_girder_z + P_w_k);
        [P_x,P_y,P_z] = sidespan_CableA.P(sidespan_CableA.Params.Index_Hanger,ones(1,length(P_cable_z)),ones(1,length(P_cable_z)),-P_cable_z);
    else
        [P_x,P_y,P_z] = sidespan_CableA.P(false(1,length(sidespan_CableA.Point)-2),[],[],[]);
    end
    obj.Params.Params_ShapeFinding_SideSpanCableA = sidespan_CableA.Params;
    obj.Params.Params_ShapeFinding_SideSpanCableA.Init_var = sidespan_CableA.Result_ShapeFinding.x;
    obj.Params.Params_ShapeFinding_SideSpanCableA.F_x = F_x;
    sidespan_CableA.Params = obj.Params.Params_ShapeFinding_SideSpanCableA;
    sidespan_CableA.findShape(P_x,P_y,P_z);
    
    sidespan_CableB = sidespan_CableBs(1);
    hanger = sidespan_CableB.findConnectStructureByClass('Hanger');
    if ~isempty(hanger)
        P_girder_z = obj.getGirderPz(hanger,X,Pz);
        w = hanger.Material.MaterialData.gamma .* hanger.Section.Area; % 每延米自重
        P_w_k = -w.*hanger.getUnstressedLengthByForce(-P_girder_z);
        P_cable_z = abs(P_girder_z + P_w_k);
        [P_x,P_y,P_z] = sidespan_CableB.P(sidespan_CableB.Params.Index_Hanger,ones(1,length(P_cable_z)),ones(1,length(P_cable_z)),-P_cable_z);
    else
        [P_x,P_y,P_z] = sidespan_CableB.P(false(1,length(sidespan_CableB.Point)-2),[],[],[]);
    end
    obj.Params.Params_ShapeFinding_SideSpanCableB = sidespan_CableB.Params;
    obj.Params.Params_ShapeFinding_SideSpanCableB.Init_var = sidespan_CableB.Result_ShapeFinding.x;
    obj.Params.Params_ShapeFinding_SideSpanCableB.F_x = F_x;
    sidespan_CableB.Params = obj.Params.Params_ShapeFinding_SideSpanCableB;
    sidespan_CableB.findShape(P_x,P_y,P_z);

    [dx,~,dz] = sidespan_CableA.Line(1).DeltaLength;
    ForceA_Z = abs(2 * F_x * dz / dx);
    
    [dx,~,dz] = sidespan_CableB.Line(end).DeltaLength;
    ForceB_Z = abs(2 * F_x * dz / dx);
end
%{
function [ForceA_Z,ForceB_Z] = getAnchorForce_ByShapeFinding(obj,X,Pz,index_sidespan_CableA,index_sidespan_CableB)
    cables = obj.ReplacedCable;
    index_mainspan_Cable = (~index_sidespan_CableA) & (~index_sidespan_CableB);
    mainspan_cables = cables(index_mainspan_Cable);
    sidespan_CableAs = cables(index_sidespan_CableA);
    sidespan_CableBs = cables(index_sidespan_CableB);
    % 主跨主缆
    mainspan_cable = mainspan_cables(1);
    hanger = mainspan_cable.findConnectStructureByClass('Hanger');
    P_girder_z = obj.getGirderPz(hanger,X,Pz);
    w = hanger.Material.MaterialData.gamma .* hanger.Section.Area; % 每延米自重
    P_w_k = -w.*hanger.getUnstressedLengthByForce(-P_girder_z/2);
    [~,sign_cable_tension] = hanger.getHangerTensionDirectionAtCable();
    P_cable_z = abs(P_girder_z/2 + P_w_k) .* sign_cable_tension(:,3)';
    [P_x,P_y,P_z] = mainspan_cable.P(mainspan_cable.Params.Index_Hanger,ones(1,length(P_cable_z)),ones(1,length(P_cable_z)),-P_cable_z);
    Params = mainspan_cable.Params;
    Params.Init_var = mainspan_cable.Result_ShapeFinding.x;
    mainspan_cable.Params = Params;
    mainspan_cable.findShape(P_x,P_y,P_z);
    F_x = mainspan_cable.Result_ShapeFinding.F_x;
    % 边跨主缆A
    sidespan_CableA = sidespan_CableAs(1);
    [P_x,P_y,P_z] = sidespan_CableA.P(false(1,length(sidespan_CableA.Point)-2),[],[],[]);
    Params = sidespan_CableA.Params;
    Params.Init_var = sidespan_CableA.Result_ShapeFinding.x;
    Params.F_x = F_x;
    sidespan_CableA.Params = Params;
    sidespan_CableA.findShape(P_x,P_y,P_z);
    % 边跨主缆B
    sidespan_CableB = sidespan_CableBs(1);
    [P_x,P_y,P_z] = sidespan_CableB.P(false(1,length(sidespan_CableB.Point)-2),[],[],[]);
    Params = sidespan_CableB.Params;
    Params.Init_var = sidespan_CableB.Result_ShapeFinding.x;
    Params.F_x = F_x;
    sidespan_CableB.Params.F_x = F_x;
    sidespan_CableB.findShape(P_x,P_y,P_z);

    % 
    [dx,~,dz] = sidespan_CableA.Line(1).DeltaLength;
    ForceA_X = sidespan_CableA.Result_ShapeFinding.HorizontalForce(1);
    ForceA_Z = 2* ForceA_X *dz / dx;
    %
    [dx,~,dz] = sidespan_CableB.Line(end).DeltaLength;
    ForceB_X = -sidespan_CableB.Result_ShapeFinding.HorizontalForce(end);
    ForceB_Z = 2* ForceB_X *dz / dx;
end
%}