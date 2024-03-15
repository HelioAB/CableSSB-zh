function data_container = solveCableShape(obj,Pz)
    % Pz是所有设计竖向力的汇总，包括了斜拉索处的设计竖向力

    % 1. 寻找那些需要被求解的Cable对象及其Hanger对象，对称的主缆仅操作其中之一的主缆（破坏了对称性，因此需要第5步的恢复对称性）
    ReplaceCables = obj.ReplacedCable;
    Index_SeletedCables = true(1,length(ReplaceCables));
    for i=1:length(ReplaceCables)
        if ~isfield(ReplaceCables(i).RelatedToStructure,'Relation')
        elseif strcmp(ReplaceCables(i).RelatedToStructure.Relation,'Symmetrized From')
            Index_SeletedCables(i) = false;
        end
    end
    SelectedCables = ReplaceCables(Index_SeletedCables);
    
    % 数据存储在 data_container 中
    data_container = DataContainer();
    X = obj.XCoordOfPz;
    
    for i=1:length(SelectedCables)
        cable = SelectedCables(i);
        hanger = cable.findConnectStructureByClass('Hanger');
    % 2. 求解吊索上吊点位置
        if ~isempty(hanger)
            hanger_clone = hanger.clone();
            HangerTopPoints = hanger_clone.findCablePoint();
            HangerBottomPoints = hanger_clone.findGirderPoint();
            X_T_0 = [HangerTopPoints.X];
            Y_T_0 = [HangerTopPoints.Y];
            Z_T_0 = [HangerTopPoints.Z];
            X_B_0 = [HangerBottomPoints.X];
            Y_B_0 = [HangerBottomPoints.Y];
            Z_B_0 = [HangerBottomPoints.Z];
        
            P_girder_z = zeros(1,length(X_B_0));

            % 从所有设计竖向力的汇总Pz中，提取出与吊索相关的设计竖向力P_girder_z
            for j=1:length(X)
                index = abs(X(j)-X_B_0) < 1e-5;
                P_girder_z(index) = Pz(j);
            end

            w = hanger_clone.Material.MaterialData.gamma .* hanger_clone.Section.Area; % 每延米自重
            
            ObjFunc = @(Y) MSE_Y(Y,cable,hanger_clone,P_girder_z,w,X_T_0,Z_T_0,X_B_0,Y_B_0,Z_B_0,data_container);
            A = [];
            b = [];
            Aeq = [];
            beq = [];
            lb = zeros(size(Y_B_0));
            ub = zeros(size(Y_B_0));
            for j=1:length(Y_B_0)
                lb(j) = min([Y_B_0,0]);
                ub(j) = max([Y_B_0,0]);
            end
            Y_0 = (lb + ub)/2;
            nonlcon = [];
            
            options = optimoptions('fmincon','Display','iter-detailed','ObjectiveLimit',5e-2,'DiffMinChange',0.01);
            fmincon(ObjFunc,Y_0,A,b,Aeq,beq,lb,ub,nonlcon,options);
            
    % 5. 恢复主缆的对称性
            cable.resumeSymmetrical;
    % 6. 恢复吊索力
            hanger.getP(P_girder_z);
        end
    end
end
function MSE = MSE_Y(Y_0,cable,hanger,P_girder_z,w,X_T_0,Z_T_0,X_B_0,Y_B_0,Z_B_0,data_container)
    HangerTopPoints = hanger.findCablePoint();
    for i=1:length(HangerTopPoints)
        HangerTopPoints(i).Y = Y_0(i);
    end
    delta_x = X_T_0 - X_B_0;
    delta_y = Y_0 - Y_B_0;
    delta_z = Z_T_0 - Z_B_0;
    
    [~,sign_cable_tension] = hanger.getHangerTensionDirectionAtCable();
    sign_girder_tension = -sign_cable_tension;
    P_w_k = -w.*hanger.getUnstressedLengthByForce(-P_girder_z);

    P_girder_z = abs(P_girder_z) .* sign_girder_tension(:,3)';
    P_girder_y = abs((P_girder_z + P_w_k/2) .* delta_y ./ delta_z) .* sign_girder_tension(:,2)';
    P_girder_x = abs((P_girder_z + P_w_k/2) .* delta_x ./ delta_z) .* sign_girder_tension(:,1)';

    P_cable_z = abs(P_girder_z + P_w_k) .* sign_cable_tension(:,3)';
    P_cable_y = -P_girder_y;
    P_cable_x = -P_girder_x;

    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,-P_cable_x,-P_cable_y,-P_cable_z);
    Params = cable.Params;
    Params.Init_var = cable.Result_ShapeFinding.x;
    cable.Params = Params;
    cable.findShape(P_x,P_y,P_z);
    cablePoints = cable.Point;
    HangerTopPoints = cablePoints([false,cable.Params.Index_Hanger,false]);
    Y_HangerTop_after = [HangerTopPoints.Y];

    MSE = sum((Y_HangerTop_after - Y_0).^2);
end