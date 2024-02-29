function [bridge_findState,U_final] = optimBendingStrainEnergy(obj)
    if ~obj.isFindingReasonalState
        overall_dir = '.\Output Files\findReasonalState\';
        mkdir_IgnoreWarning(overall_dir)

        X = obj.getSortedGirderPointXCoord([obj.findStructureByClass('Hanger'),obj.findStructureByClass('StayedCable')]);
        bridge_findState = obj.getNonCableBridge(X);
        assignin("base","bridge_findState",bridge_findState)
        fun = @(Pz) ObjFun(bridge_findState,X,Pz,overall_dir);
        x0 = obj.getAverageGirderWeight + zeros(1,length(X));
        A = [];
        b = [];
        Aeq = [];
        beq = [];
        lb = zeros(1,length(X)); % Pz大于等于0，即缆索受拉
        ub = obj.getGirderWeight+zeros(1,length(X)); % Pz不大于全桥总重
        nonlcon = [];
        options = optimoptions('fmincon','Display','iter','DiffMinChange',1e4);

        [Pz_final,U_final] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    end
end
function U = ObjFun(bridge_findState,X,Pz,overall_dir)
    % 第i次迭代
    changeLoadValue(bridge_findState,X,Pz);
    i = bridge_findState.Iteration_ReasonalStateFinding;
    % 每次迭代都在一个工作目录下进行
    iter_dir = [overall_dir,'Iter_',num2str(i)];
    mkdir_IgnoreWarning(iter_dir)
    output_method = OutputToAnsys(bridge_findState,"JobName",['Iter_',num2str(i)],...
                                                     'WorkPath',iter_dir,...
                                                     'MacFilePath',[iter_dir,'\main.mac'],...
                                                     'ResultFilePath',[iter_dir,'\Iter_',num2str(i),'.out']);
    bridge_findState.OutputMethod = output_method;
    bridge_findState.output;
    bridge_findState.run;
    % 需要计算的Structure
    tower_list = bridge_findState.findStructureByClass('Tower');
    girder_list = bridge_findState.findStructureByClass('Girder');
    structure_list = [girder_list,tower_list];
    params = struct;
    params.DataFolderDirecotry = 'Data_BendingStrainEnergy';
    params.BendingStrainEnergyStructure = structure_list;
    params.DataFileName = cellfun(@(x) {x.Name},structure_list);
    % 导出弯曲应变能需要的参数
    bridge_findState.OutputMethod.outputPostProcessing(params)
    bridge_findState.run('MacFilePath','defPostProcessing.mac')
    % 计算总弯曲应变能
    Map_MatlabLine2AnsysElem = bridge_findState.Params.Map_MatlabLine2AnsysElem;
    U = 0;
    for j=1:length(structure_list)
        % 导入弯曲应变能参数
        input_method = InputFromTXT([iter_dir,'\Data_BendingStrainEnergy\',params.DataFileName{j},'.txt']);
        RawData = input_method.txtToRawData(11);
        bridge_findState.InputMethod.(['InputBendingStrainEnergy_',params.DataFileName{j}]) = input_method;
        % 弯曲应变能参数的处理
        [L,E,I,M_i,M_j] = RawDataToInfo(RawData,structure_list{j},Map_MatlabLine2AnsysElem);
        % 计算总弯曲应变能
        U = U + computeBendingStrainEnergy(L,E,I,M_i,M_j);
    end
    format longEng
    U
    format default
    Pz
    % 保存结果
    bridge_findState.Iteration_Result.(['Iter_',num2str(i)]) = struct;
    bridge_findState.Iteration_Result.(['Iter_',num2str(i)]).Iteration = i;
    bridge_findState.Iteration_Result.(['Iter_',num2str(i)]).U = U;
    bridge_findState.Iteration_Result.(['Iter_',num2str(i)]).Pz = Pz;
    % 迭代次数+1
    bridge_findState.Iteration_ReasonalStateFinding = i+1;
end
function changeLoadValue(bridge_findState,X,Pz)
    bridge_findState.LoadList = {};
    % 集中荷载代替斜拉索作用: 作用在梁上、塔上
    stayedcable_list = bridge_findState.Params.StayedCable_findReasonalState;
    for i=1:length(stayedcable_list)
        stayedcable_i = stayedcable_list{i};
        [load_cable_cell_i,load_girder_cell_i] = useLoadInsteadOfStayedCable(stayedcable_i,X,Pz);
        for j=1:3
            bridge_findState.addLoad(load_cable_cell_i{j})
        end
        for j=1:3
            bridge_findState.addLoad(load_girder_cell_i{j})
        end
    end
    % 集中荷载代替吊索作用：作用在梁上、自锚
    hanger_list = bridge_findState.Params.Hanger_findReasonalState;
    for i=1:length(hanger_list)
        hanger_i = hanger_list{i};
        load_girder_cell_i = useLoadInsteadOfHanger(hanger_i,X,Pz);
        for j=1:3
            bridge_findState.addLoad(load_girder_cell_i{j})
        end
    end
end
function [L,E,I,M_i,M_j] = RawDataToInfo(RawData,structure,Map_MatlabLine2AnsysElem)
    num_elem = RawData(:,1);
    E = RawData(:,2);
    Iyy_sec = RawData(:,3);
    Izz_sec = RawData(:,4);
    Iyy_real = RawData(:,5);
    Izz_real = RawData(:,6);
    L = RawData(:,7);
    Myi = RawData(:,8);
    Mzi = RawData(:,9);
    Myj = RawData(:,10);
    Mzj = RawData(:,11);
    
    if isa(structure.ElementType,'Beam4')
        Iyy = Iyy_real;
        Izz = Izz_real;
    else
        Iyy = Iyy_sec;
        Izz = Izz_sec;
    end
    line = structure.Line;
    normal_moment = [0,1,0];% 弯矩平面X-Z的法线
    [~,Comp_y,Comp_z] = line.getLocalCoordSystemComponent(normal_moment);% 获得法线向单元坐标系y和z轴的投影
    I = zeros(1,length(num_elem));
    M_i = zeros(1,length(num_elem));
    M_j = zeros(1,length(num_elem));
    for i=1:length(line)
        num_elem_line = Map_MatlabLine2AnsysElem(line(i).Num);
        for j = 1:length(num_elem_line)
            num_elem_line_j = num_elem_line(j);
            index_elem_j = num_elem == num_elem_line_j;
            Iyy_j = Iyy(index_elem_j);
            Izz_j = Izz(index_elem_j);
            Myi_j = Myi(index_elem_j);
            Mzi_j = Mzi(index_elem_j);
            Myj_j = Myj(index_elem_j);
            Mzj_j = Mzj(index_elem_j);

            I(index_elem_j) = Iyy_j*Comp_y(i) + Izz_j*Comp_z(i);
            M_i(index_elem_j) = Myi_j*Comp_y(i) + Mzi_j*Comp_z(i);
            M_j(index_elem_j) = Myj_j*Comp_y(i) + Mzj_j*Comp_z(i);
        end
    end
    % 去除I==0的数据
    index_I_nonzero = abs(I)>1e-5; % I不为0的index。I为0一般是单元朝向正好是全局坐标系的Y方向
    L = L(index_I_nonzero)';
    E = E(index_I_nonzero)';
    I = I(index_I_nonzero);
    M_i = M_i(index_I_nonzero);
    M_j = M_j(index_I_nonzero);
end
function U = computeBendingStrainEnergy(L,E,I,M_i,M_j)
    arguments
        L
        E {mustBeEqualSize(L,E)}
        I {mustBeEqualSize(L,I)}
        M_i {mustBeEqualSize(L,M_i)}
        M_j {mustBeEqualSize(L,M_j)}
    end
    U = sum(L./(6*E.*I).*(M_i.^2 + M_i.*M_j + M_j.^2));
end
function [load_tower,load_girder] = useLoadInsteadOfStayedCable(stayedcable,X,Pz)
    % 输入：
    %   stayedcable: 一个StayedCable对象
    %   P_z: 数值向量；P_z(i) 对应 stayedcable.Line(i)
    % 输出：
    %   load_tower: 3个Load对象组成的cell；表示替换StayedCable在桥塔上的集中荷载
    %   load_girder: 3个Load对象组成的cell；表示替换StayedCable在加劲梁上的集中荷载
    Pz_girder = getGirderPz(stayedcable,X,Pz);
    girder_point = stayedcable.findGirderPoint;
    tower_point = stayedcable.findTowerPoint;
    [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = stayedcable.getP(Pz_girder);
    
    load_tower_x = ConcentratedForce(tower_point,'X',-P_tower_x);
    load_tower_y = ConcentratedForce(tower_point,'Y',-P_tower_y);
    load_tower_z = ConcentratedForce(tower_point,'Z',-P_tower_z);

    load_girder_x = ConcentratedForce(girder_point,'X',-P_girder_x);
    load_girder_y = ConcentratedForce(girder_point,'Y',-P_girder_y);
    load_girder_z = ConcentratedForce(girder_point,'Z',-P_girder_z);

    load_tower_x.Name = [stayedcable.Name,'_TowerForce_X'];
    load_tower_y.Name = [stayedcable.Name,'_TowerForce_Y'];
    load_tower_z.Name = [stayedcable.Name,'_TowerForce_Z'];

    load_girder_x.Name = [stayedcable.Name,'_GirderForce_X'];
    load_girder_y.Name = [stayedcable.Name,'_GirderForce_Y'];
    load_girder_z.Name = [stayedcable.Name,'_GirderForce_Z'];

    load_tower = {load_tower_x,load_tower_y,load_tower_z};
    load_girder = {load_girder_x,load_girder_y,load_girder_z};
end
function load_girder = useLoadInsteadOfHanger(hanger,X,Pz)
    % 输入：
    %   stayedcable: 一个StayedCable对象
    %   P_z: 数值向量；P_z(i) 对应 stayedcable.Line(i)
    % 输出：
    %   load_tower: 3个Load对象组成的cell；表示替换StayedCable在桥塔上的集中荷载
    %   load_girder: 3个Load对象组成的cell；表示替换StayedCable在加劲梁上的集中荷载
    Pz_girder = getGirderPz(hanger,X,Pz);
    girder_point = hanger.findGirderPoint;
    [~,~,~,P_girder_x,P_girder_y,P_girder_z] = hanger.getP(Pz_girder);
    
    load_girder_x = ConcentratedForce(girder_point,'X',-P_girder_x);
    load_girder_y = ConcentratedForce(girder_point,'Y',-P_girder_y);
    load_girder_z = ConcentratedForce(girder_point,'Z',-P_girder_z);

    load_girder_x.Name = [hanger.Name,'_GirderForce_X'];
    load_girder_y.Name = [hanger.Name,'_GirderForce_Y'];
    load_girder_z.Name = [hanger.Name,'_GirderForce_Z'];

    load_girder = {load_girder_x,load_girder_y,load_girder_z};
end

function [Pz_girder,index]= getGirderPz(structure,X,Pz)
    % 输入按X排序的Pz，输出Structure可以直接使用的Pz
    girder_point = structure.findGirderPoint;
    X_girder_point = [girder_point.X];
    Pz_girder = zeros(1,length(X_girder_point));
    index = {};
    for i=1:length(X)
        index_i = abs(X(i)-X_girder_point) < 1e-5;
        index{1,end+1} = index_i;
        Pz_girder(index_i) = Pz(i);
    end
end
function mkdir_IgnoreWarning(new_folder)
    % 忽略"已存在目录"的警告信息
    try 
        [status,msg,msgID] = mkdir(new_folder);
    catch ME
        switch ME.identifier
            case 'MATLAB:MKDIR:DirectoryExists'
            otherwise
                rethrow(ME)
        end
    end
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end
