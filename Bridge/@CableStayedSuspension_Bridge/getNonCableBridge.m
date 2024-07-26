function bridge_findState = getNonCableBridge(obj,X,Pz)
    arguments
        obj
        X {mustBeNumeric} = obj.getSortedGirderPointXCoord([obj.findStructureByClass('Hanger'),obj.findStructureByClass('StayedCable')])
        Pz {mustBeNumeric} = obj.getAverageGirderWeight + zeros(1,length(X))
    end
    % 将原Bridge复制到一个新的找合理成桥状态专用的Bridge对象中去
    bridge_findState = obj.clone;
    
    % 提取出 Hanger Cable StayedCable 
    [hanger_list,index_hanger] = obj.findStructureByClass('Hanger'); % hanger_list是对象素组
    bridge_findState.Params.Hanger_findReasonalState = hanger_list;
    [cable_list,index_cable] = obj.findStructureByClass('Cable');
    bridge_findState.Params.Cable_findReasonalState = cable_list;
    [stayedcable_list,index_stayedcable] = obj.findStructureByClass('StayedCable');
    bridge_findState.Params.StayedCable_findReasonalState = stayedcable_list;
    [pier_list,index_pier] = obj.findStructureByClass('Pier');
%     PierCoupling = bridge_findState.CouplingList(obj.Params.index_PierCoupling);
    
    % 在bridge_findState中删除与 Hanger Cable StayedCable 相关的和Pier:
    % Material、Section、ElementType、ElementDivision、Coupling、Load、Constraint
    delete_structure_index = index_hanger | index_cable | index_stayedcable | index_pier;
    bridge_findState.MaterialList(delete_structure_index) = [];
    bridge_findState.SectionList(delete_structure_index) = [];
    bridge_findState.ElementTypeList(delete_structure_index) = [];
    bridge_findState.ElementDivisionList(delete_structure_index) = [];
    bridge_findState.StructureList(delete_structure_index) = [];
    
    % bridge_findState.CouplingList(obj.Params.index_CableCoupling | obj.Params.index_PierCoupling) = [];
    % bridge_findState.ConstraintList(obj.Params.index_CableConstraint | obj.Params.index_PierConstraint) = [];

%     for i=1:length(PierCoupling)
%         girder_point = PierCoupling{i}.SlavePoint;
%         dof = PierCoupling{i}.DoF.Name;
%         bridge_findState.addConstraint(girder_point,dof,zeros(1,length(dof)),'Name',['辅助墩固结',num2str(i)]);
%     end

    % 将Beam18*的AdditionalNode改为0
    for i=1:length(bridge_findState.ElementTypeList)
        ET = bridge_findState.ElementTypeList{i};
        if strcmpi(class(ET),'Beam188') || strcmpi(class(ET),'Beam189') % 只有Beam188和Beam189才能修改AdditionalNode属性
            ET.AdditionalNode = 0; % 将额外节点个数设置为0
        end
    end

    % bridge_findState.LoadList = {};
    % 集中荷载代替斜拉索作用: 作用在梁上、塔上
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
    for i=1:length(hanger_list)
        hanger_i = hanger_list{i};
        load_girder_cell_i = useLoadInsteadOfHanger(hanger_i,X,Pz);
        for j=1:3
            bridge_findState.addLoad(load_girder_cell_i{j})
        end
    end
    % 主缆塔顶力
    % 主缆锚碇力
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


function Pz_girder = getGirderPz(structure,X,Pz)
    % 输入按X排序的Pz，输出Structure可以直接使用的Pz
    girder_point = structure.findGirderPoint;
    X_girder_point = [girder_point.X];
    Pz_girder = zeros(1,length(X_girder_point));
    for i=1:length(X)
        index = abs(X(i)-X_girder_point) < 1e-5;
        Pz_girder(index) = Pz(i);
    end
end