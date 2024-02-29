function solveCableShape(obj)
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

    % 获得最小弯曲应变能后的解
    max_iter = obj.Iter_Optimization;
    Pz = obj.Result_Iteration.Iter_Pz(max_iter);
    X = obj.XCoordOfPz;

    for i=1:length(SelectedCables)
        cable = SelectedCables(i);
        hanger = cable.findConnectStructureByClass('Hanger');
    % 2. 求解吊索上吊点位置
        if ~isempty(hanger)
            % 循环求解Y：因为要不断变化最小有限差分，所以需要循环
            exitflag = 2;
            x0 = cable.Result_ShapeFinding.Y(cable.Params.Index_Hanger);
            fval = 100;
            step = 1;
            ObjectiveLimit = 5e-2;
            while (fval>ObjectiveLimit) && (exitflag==2) && (step>1e-12) % 如果停止了并且fval还比较大，就减小DiffMinChange为原来的0.001
                [x1,fval,exitflag] = solveHangerTopCoordY(obj,cable,hanger,data_container,"x0",x0,"MinDiffChange",step,'ObjectiveLimit',ObjectiveLimit);
                x0 = x1;
                step = step*0.001;
            end
            % 循环求解Z
    % 3. 求解吊索上吊点力
            P_girder_z = obj.getGirderPz(hanger,X,Pz);
            [~,~,P_cable_z] = hanger.getP(P_girder_z);
            [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,[],[],-P_cable_z);
            cable.findShape(P_x,P_y,P_z);
            [P_cable_x,P_cable_y,P_cable_z] = getHangerForceByOptimizedVariables(x0,hanger,P_girder_z);
    % 4. 主缆重新找形
            [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,-P_cable_x,-P_cable_y,-P_cable_z);
            cable.findShape(P_x,P_y,P_z);
            data_container.Data.cable = cable;
            data_container.Data.hanger = hanger;
    % 5. 恢复主缆的对称性
            cable.resumeSymmetrical;
        end
    end
    % 6. 斜拉索索力
    for i=1:length(obj.ReplacedStayedCable)
        stayed_cable = obj.ReplacedStayedCable(i);
        P_girder_z = obj.getGirderPz(stayed_cable,X,Pz);
        stayed_cable.getP(P_girder_z);
    end
    
end
function [x,fval,exitflag] = solveHangerTopCoordY(obj,cable,hanger,data_container,options)% 或许可以把这个函数写在Cable类中去
    arguments
        obj
        cable
        hanger
        data_container
        options.Data = []
        options.x0 = zeros(1,length(hanger.Line)) % 如果要在某个初始点继续优化，设置该值
        options.MaxIteration = 100 % 多大迭代次数
        options.MinDiffChange = 1 % 最小差分数，如果设置得比较大，可能不能收敛到最小值；如果设置地比较小，计算量太大
        options.ObjectiveLimit = 5e-2 % 目标函数到多少时就可以收敛
    end
    % 1. 获得作用在Cable上的吊杆力的竖向分力
    max_iter = obj.Iter_Optimization;
    Pz = obj.Result_Iteration.Iter_Pz(max_iter);
    X = obj.XCoordOfPz;
    P_girder_z = obj.getGirderPz(hanger,X,Pz);
    [~,~,P_cable_z] = hanger.getP(P_girder_z);
    
    % 2. 设置优化的初始条件：只有竖向力作用的Cable，找形并获取此时Cable的吊点XYZ位置
    % 优化变量为：仅在竖向力作用下的主缆的上吊点位置 的 偏离量
    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,[],[],-P_cable_z);
    cable.findShape(P_x,P_y,P_z);
    CablePoint = hanger.findCablePoint;
    sorted_CablePoint = CablePoint.sort('X');
    GirderPoint = hanger.findGirderPoint;
    sorted_GirderPoint = GirderPoint.sort('X');
    count_hanger = length(GirderPoint);

    % 3. 设置优化变量的约束条件：Cable的吊点XYZ位置需要在一定范围之内
    % 为Cable两端点之间插值插入Point对象数组
    CablePointA = cable.PointA;
    CablePointB = cable.PointB;
    CableEndPoints = [CablePointA,CablePointB];
    Index_Hanger = [cable.Params.Index_Hanger,true];
    count_interval = sum(Index_Hanger);
    interval = zeros(1,count_interval);
    L = cable.Params.L;
    temp_sum = 0;
    flag = 1;
    for i=1:length(L)
        if Index_Hanger(i) % 如果是吊杆
            temp_sum = temp_sum + L(i);
            interval(flag) = temp_sum;
            flag = flag + 1;
            temp_sum = 0;
        else
            temp_sum = temp_sum + L(i);
        end
    end
    InterpolatedPoints = CableEndPoints.interpolatePoints('Interval',interval);
    % Cable的吊索点的Y坐标 Y_CablePoint 应该满足： Min(Y_HangerGirderPoint,Y_InterpolatedPoints) <= Y_CablePoint <= Max(Y_HangerGirderPoint,Y_InterpolatedPoints)
    % 同时，前述初值正好在边界上，因此，需要将 Y_InterpolatedPoints 移动一点点
    ub = zeros(1,count_hanger);
    lb = zeros(1,count_hanger);
    for i=1:count_hanger
        % Y方向的上下限
        YCablePoint = sorted_CablePoint(i).Y;
        YGirderPoint = sorted_GirderPoint(i).Y;
        YInterpolatedPoint = InterpolatedPoints(i).Y;
        if YGirderPoint > YInterpolatedPoint % 上下限为顺桥向平面到吊索下吊点平面
            ub(i) = YGirderPoint - YCablePoint;
            lb(i) = YInterpolatedPoint - YCablePoint;
        elseif YGirderPoint < YInterpolatedPoint
            ub(i) = YInterpolatedPoint - YCablePoint;
            lb(i) = YGirderPoint - YCablePoint;
        elseif YGirderPoint == YInterpolatedPoint
            ub(i) = YGirderPoint - YCablePoint + 0.1;
            lb(i) = YInterpolatedPoint - YCablePoint - 0.1;
        end
    end
    % 4. 求解优化问题
    ObjFun = @(DeltaCoord) L2NormOfCoordY(DeltaCoord,hanger,cable,P_girder_z,data_container);
    x0 = options.x0;
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    nonlcon = [];
    options = optimoptions('fmincon','Display','iter-detailed','DiffMinChange',options.MinDiffChange,...
                            'MaxFunctionEvaluations',(length(x0)+1)*options.MaxIteration,'ObjectiveLimit',options.ObjectiveLimit); % 最小步长设置为1kN,每次优化有进行100个迭代
    [x,fval,exitflag] = fmincon(ObjFun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
end
function L2Norm = L2NormOfCoordY(DeltaCoord,hanger,cable,P_girder_z,data_container)
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
        error('优化变量 DeltaCoord 的向量长度应为 吊索数')
    end
    sorted_CablePoint_hanger.translate([zeros(len,1),DeltaCoord',zeros(len,1)]);

    % 3. 计算吊索力 F_{hanger}(CableCoord_0 + DeltaCoord)
    [P_cable_x,P_cable_y,P_cable_z] = hanger_cloned.getP(P_girder_z); % P_cable均为吊索受力，作用在主缆上时，需要反号

    % 4. 作用吊索力之后的主缆线形 CableCoord(F_{hanger}(CableCoord_0 + DeltaCoord))
    [P_x,P_y,P_z] = cable_cloned.P(cable.Params.Index_Hanger,-P_cable_x,-P_cable_y,-P_cable_z);
    cable_cloned.findShape(P_x,P_y,P_z);
    % 存储到 data_container 中
    data_container.Data.P_x = P_x;
    data_container.Data.P_y = P_y;
    data_container.Data.P_z = P_z;
    data_container.Data.cable_cloned = cable_cloned;
    data_container.Data.hanger_cloned = hanger_cloned;
    
    % 5. 均方误差 MSE CableCoord(F_{hanger}(CableCoord_0 + DeltaCoord)) - (CableCoord_0 + DeltaCoord) = 0
    index_hanger = [false,cable_cloned.Params.Index_Hanger,false];
    CablePoint_cable = cable_cloned.Point(index_hanger); % 吊索吊点
    sorted_CablePoint_cable = CablePoint_cable.sort('X');
    ErrorCoord = sorted_CablePoint_cable.Coord - sorted_CablePoint_hanger.Coord;
    L2Norm = sqrt(sum(ErrorCoord(:,2).^2));
end
function [P_cable_x,P_cable_y,P_cable_z] = getHangerForceByOptimizedVariables(OptimizedVariables,hanger,P_girder_z)
    count_variable = length(OptimizedVariables);
    DeltaCoord = [zeros(1,count_variable)',OptimizedVariables',zeros(1,count_variable)'];

    cable_point = hanger.findCablePoint;
    SortedCablePoint_hanger = cable_point.sort('X');
    SortedCablePoint_hanger.translate(DeltaCoord); % 移动吊索上吊点
    [P_cable_x,P_cable_y,P_cable_z] = hanger.getP(P_girder_z); 
end