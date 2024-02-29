function optimBendingStrainEnergy(obj,options)
    arguments
        obj
        options.MaxIter = 10
        options.DiffMinChange = 1e3
        options.Initial_Iter (1,1) {mustBeNumeric} = 0 % 修改options的各个参数，可以继续之前的优化
        options.Initial_Iter_U {mustBeA(options.Initial_Iter_U,'containers.Map')} = containers.Map('KeyType','double','ValueType','any')
        options.Initial_Iter_Pz {mustBeA(options.Initial_Iter_Pz,'containers.Map')} = containers.Map('KeyType','double','ValueType','any')
    end
    % 显示进度
    disp('Is optimizing the Bending Strain Energy...')
    % 初始弯曲应变能
    X = obj.OriginalBridge.getSortedGirderPointXCoord([obj.OriginalBridge.findStructureByClass('Hanger'),obj.OriginalBridge.findStructureByClass('StayedCable')]);
    
    % 初始化需要存储记录的参数
    obj.isOptimizing = true;
    obj.Iter_Optimization = options.Initial_Iter;
    obj.Result_Iteration.Iter_U = options.Initial_Iter_U;
    obj.Result_Iteration.Iter_Pz = options.Initial_Iter_Pz;

    % 优化参数设置
    fun = @(Pz) ObjFun(Pz,X,obj);
    if isempty(obj.Result_Iteration.Iter_Pz) % 如果在此之前还未进行优化
        x0 = obj.getAverageGirderWeight + zeros(1,length(X));
    else % 如果继续之前的进行优化
        x0 = options.Initial_Iter_Pz(options.Initial_Iter);
    end
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = 1000+zeros(1,length(X)); % Pz大于等于1kN，即缆索受拉
    ub = obj.getGirderWeight/2+zeros(1,length(X)); % Pz不大于全桥总重的一半
    nonlcon = [];
    options = optimoptions('fmincon', ...
                           'Display','iter', ...
                           'DiffMinChange',options.DiffMinChange, ...
                           'MaxFunctionEvaluations',(length(x0)+1)*options.MaxIter, ...
                           'PlotFcn', 'optimplotfval'); % 最小步长设置为1kN,每次优化有进行100个迭代
    
    % 优化
    [Pz_final,U_final] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    obj.isOptimizing = false;
    obj.FiniteElementModel.TempResult = rmfield(obj.FiniteElementModel.TempResult,'computingDisplacement');
end
function U = ObjFun(Pz,X,obj)
    % 计算弯曲应变能结果
    obj.LoadList = {}; % 修改obj.LoadList，而不是使用obj.addLoad，避免记录Load对象
    Load_Hanger = obj.replaceHangerByForce(X,Pz);
    Load_StayedCable = obj.replaceStayedCableByForce(X,Pz);
    obj.LoadList = [Load_Hanger,Load_StayedCable];
    obj.replaceRHSByLoad;
    obj.FiniteElementModel.computeDisplacement; % 求解整体坐标系下的节点位移
    obj.FiniteElementModel.completeDisplacement; % 补全因Constraint、Coupling而删去的方程
    elements = obj.FiniteElementModel.Element;
    U = sum(elements.getBendingStrainEnergy);
    
    % 存储结果
    obj.Iter_Optimization = obj.Iter_Optimization + 1; % 迭代次数
    obj.Result_Iteration.Iter_U(obj.Iter_Optimization) = U; % 存储第obj.Iter_Optimization次的弯曲应变能结果
    obj.Result_Iteration.Iter_Pz(obj.Iter_Optimization) = Pz; % 存储第obj.Iter_Optimization次的缆索竖向力结果
end
function [c,ceq,grad_c,grad_ceq] = NonliearControl(Pz,X,obj) % 非线性约束
    % c <= 0
    % ceq == 0
    % grad_c
    % grad_ceq
    c = [];
    ceq = [];
    if nargout > 2
        % 如果使用了梯度，就需要设置 options = optimoptions(@fmincon,'SpecifyConstraintGradient',true);
        grad_c = [];
        grad_ceq = [];
    end
end
