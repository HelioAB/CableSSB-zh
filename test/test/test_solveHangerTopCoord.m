obj = bridge_state;
Map_Pz = obj.Result_Iteration.Iter_Pz;
max_iter = obj.Iter_Optimization;
% 第12008次迭代的索力
Pz = Map_Pz(max_iter);



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

cable = SelectedCables(1);
hanger = cable.findConnectStructureByClass('Hanger');
% 2. 求解吊索上吊点位置
if ~isempty(hanger)
    cable_clone = cable.clone;
    hanger_clone = hanger.clone;
    HangerTopPoints = hanger_clone.findCablePoint();
    HangerBottomPoints = hanger_clone.findGirderPoint();
    X_T_0 = [HangerTopPoints.X];
    Y_T_0 = [HangerTopPoints.Y];
    Z_T_0 = [HangerTopPoints.Z];
    X_B_0 = [HangerBottomPoints.X];
    Y_B_0 = [HangerBottomPoints.Y];
    Z_B_0 = [HangerBottomPoints.Z];

    P_girder_z = zeros(1,length(X_B_0));
    for j=1:length(X)
        index = abs(X(j)-X_B_0) < 1e-5;
        P_girder_z(index) = Pz(j);
    end

    w = hanger_clone.Material.MaterialData.gamma .* hanger_clone.Section.Area; % 每延米自重
    

    
    
    %
    lb = zeros(size(Y_B_0));
    ub = zeros(size(Y_B_0));
    for j=1:length(Y_B_0)
        lb(j) = min([Y_B_0,0]);
        ub(j) = max([Y_B_0,0]);
    end
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    nonlcon = [];
    Y_0 = (lb + ub)/2;
    ObjFunc = @(Y) MSE_Y(Y,cable_clone,hanger_clone,P_girder_z,w,X_T_0,Z_T_0,X_B_0,Y_B_0,Z_B_0,data_container);

    %
    % fmincon
    % options = optimoptions('fmincon','Display','iter-detailed','ObjectiveLimit',5e-2,'PlotFcn', 'optimplotfval','DiffMinChange',0.01);
    options = optimoptions('fmincon','Display','iter-detailed','ObjectiveLimit',5e-2,'DiffMinChange',0.01);
    [optim_var,fval,exitflag,output] = fmincon(ObjFunc,Y_0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    %}

% 5. 恢复主缆的对称性
    cable.resumeSymmetrical;
    %}
    % MSE_Y(zeros(size(Y_T_0)),cable_clone,hanger,P_girder_z,P_w_k,sign_cable_tension,X_T_0,Z_T_0,X_B_0,Y_B_0,Z_B_0,data_container);
end

function MSE = MSE_Y(Y_0,cable,hanger_clone,P_girder_z,w,X_T_0,Z_T_0,X_B_0,Y_B_0,Z_B_0,data_container)
    HangerTopPoints = hanger_clone.findCablePoint();
    for i=1:length(HangerTopPoints)
        HangerTopPoints(i).Y = Y_0(i);
    end
    delta_x = X_T_0 - X_B_0;
    delta_y = Y_0 - Y_B_0;
    delta_z = Z_T_0 - Z_B_0;
    
    [~,sign_cable_tension] = hanger_clone.getHangerTensionDirectionAtCable();
    sign_girder_tension = -sign_cable_tension;
    P_w_k = -w.*hanger_clone.getUnstressedLengthByForce(-P_girder_z);

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