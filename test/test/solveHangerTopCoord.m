function [x,fval,exitflag] = solveHangerTopCoord(cable,hanger,obj,options)
    arguments
        cable
        hanger
        obj
        options.Data = []
        options.x0 = zeros(1,length(hanger.Line)) % 如果要在某个初始点继续优化，设置该值
        options.MaxIteration = 10 % 多大迭代次数
        options.MinDiffChange = 1 % 最小差分数，如果设置得比较大，可能不能收敛到最小值；如果设置地比较小，计算量太大
        options.ObjectiveLimit = 1e-4 % 目标函数到多少时就可以收敛
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
    ObjFun = @(DeltaCoord) MSEOfCoordY(DeltaCoord,hanger,cable,P_girder_z);
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