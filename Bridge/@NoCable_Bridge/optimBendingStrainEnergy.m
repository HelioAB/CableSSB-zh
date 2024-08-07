function optimBendingStrainEnergy(obj,options)
    arguments
        obj
        options.MaxIter = 30
        options.DiffMinChange = 1e3
        options.ifSymmetric = true
        options.Iter (1,1) {mustBeNumeric} = 0 % 修改options的各个参数，可以继续之前的优化
        options.Map_Iter_U {mustBeA(options.Map_Iter_U,'containers.Map')} = containers.Map('KeyType','double','ValueType','any')
        options.Map_Iter_Pz {mustBeA(options.Map_Iter_Pz,'containers.Map')} = containers.Map('KeyType','double','ValueType','any')
    end
    % 显示进度
    disp('Is optimizing the Bending Strain Energy...')
    % Pz和X一一对应
    X = obj.OriginalBridge.getSortedGirderPointXCoord([obj.OriginalBridge.findStructureByClass('Hanger'),obj.OriginalBridge.findStructureByClass('StayedCable')]);
    % 初始化需要存储记录的参数
    obj.isOptimizing = true;
    obj.Iter_Optimization = options.Iter;
    obj.Result_Iteration.Map_Iter_U = options.Map_Iter_U;
    obj.Result_Iteration.Map_Iter_Pz = options.Map_Iter_Pz;
    
    % 转换设计变量
    if isempty(obj.Result_Iteration.Map_Iter_Pz) % 如果在此之前还未进行优化
        Pz_0 = obj.getAverageGirderWeight + zeros(1,length(X));
    else % 如果继续之前的进行优化
        Pz_0 = options.Map_Iter_Pz(options.Iter);
    end
    obj.Result_Iteration.ifSymmetric = options.ifSymmetric;
    if options.ifSymmetric
        index_convert = cell(1,ceil(length(Pz_0)/2));
        for i=1:length(index_convert)
            if i==length(Pz_0)-i+1
                index_convert{i} = i;
            else
                index_convert{i} = [i,length(Pz_0)-i+1];
            end
        end
        Pz_0 = convertVariable(Pz_0,index_convert,'reduce');
        obj.Result_Iteration.index_convert_var = index_convert;
    end

    % 优化参数设置
    fun = @(Pz) ObjFun(Pz,X,obj);
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = 1000+zeros(1,length(Pz_0)); % Pz大于等于1kN，即缆索受拉
    ub = obj.getGirderWeight/2+zeros(1,length(Pz_0)); % Pz不大于全桥总重的一半
    nonlcon = [];
    options = optimoptions('fmincon', ...
                           'Display','iter-detailed', ...
                           'DiffMinChange',options.DiffMinChange, ...
                           'MaxFunctionEvaluations',(length(Pz_0)+1)*options.MaxIter); % 最小步长设置为1kN,每次优化有进行100个迭代
    
    % 优化
    [Pz_final,U_final] = fmincon(fun,Pz_0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    obj.isOptimizing = false;
    obj.FiniteElementModel.TempResult = rmfield(obj.FiniteElementModel.TempResult,'computingDisplacement');
end
function U = ObjFun(Pz,X,obj)
    % 还原转换的设计变量
    if obj.Result_Iteration.ifSymmetric
        Pz = convertVariable(Pz,obj.Result_Iteration.index_convert_var,'expand');
    end

    % 计算弯曲应变能结果
    obj.LoadList = {}; % 修改obj.LoadList，而不是使用obj.addLoad，避免记录Load对象
    Load_Hanger = obj.replaceHangerByForce(X,Pz);
    Load_StayedCable = obj.replaceStayedCableByForce(X,Pz);
    Load_Cable = obj.replaceCableByForce(X,Pz);
    obj.LoadList = [Load_Hanger,Load_StayedCable,Load_Cable];
    obj.replaceRHSByLoad;
    obj.FiniteElementModel.computeDisplacement; % 求解整体坐标系下的节点位移
    obj.FiniteElementModel.completeDisplacement; % 补全因Constraint、Coupling而删去的方程
    elements = obj.FiniteElementModel.Element;
    U = sum(elements.getBendingStrainEnergy);
    
    % 存储结果
    obj.Iter_Optimization = obj.Iter_Optimization + 1; % 迭代次数
    obj.Result_Iteration.Map_Iter_U(obj.Iter_Optimization) = U; % 存储第obj.Iter_Optimization次的弯曲应变能结果
    obj.Result_Iteration.Map_Iter_Pz(obj.Iter_Optimization) = Pz; % 存储第obj.Iter_Optimization次的缆索竖向力结果
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
function converted_variable = convertVariable(variable,index_convert,mode)
    arguments
        variable (1,:) {mustBeNumeric}
        index_convert (1,:) {mustBeA(index_convert,'cell')}
        mode {mustBeMember(mode,{'reduce','expand'})} = 'reduce'
    end
    if strcmp(mode,'reduce')
        % 获得ObjFunc使用的设计变量variable
        converted_variable = zeros(1,length(index_convert));
        for i=1:length(converted_variable)
            index = index_convert{i};
            converted_variable(i) = mean(variable(index));
        end
    elseif strcmp(mode,'expand')
        % 通过variable和index_converted_variable，还原原始变量
        % 传入原始变量的长度
        len_original = 0;
        for i=1:length(index_convert)
            len_original = len_original + length(index_convert{i});
        end
        converted_variable = zeros(1,len_original);
        for i=1:length(variable)
            index = index_convert{i};
            converted_variable(index) = variable(i);
        end
    end
end

