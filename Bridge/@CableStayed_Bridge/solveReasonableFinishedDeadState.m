function bridge_findState = solveReasonableFinishedDeadState(obj)
    % 将原Bridge复制到一个新的找合理成桥状态专用的Bridge对象中去
    bridge_findState = cloneBridge(obj);
    
    % 提取出 Hanger Cable StayedCable 
    [hanger_list,index_hanger] = obj.findStructureByClass('Hanger'); % hanger_list是对象素组
    [stayedcable_list,index_stayedcable] = obj.findStructureByClass('StayedCable');

    % 在bridge_findState中删除与 Hanger Cable StayedCable 相关的:
    % Material、Section、ElementType、ElementDivision、Coupling、Load、Constraint
    delete_structure_index = index_hanger | index_cable | index_stayedcable;
    bridge_findState.MaterialList(delete_structure_index) = [];
    bridge_findState.SectionList(delete_structure_index) = [];
    bridge_findState.ElementTypeList(delete_structure_index) = [];
    bridge_findState.ElementDivisionList(delete_structure_index) = [];
    bridge_findState.StructureList(delete_structure_index) = [];
    bridge_findState.CouplingList(obj.Params.index_CableCoupling) = []; % obj.Params.index_CableCoupling通过重载的addCoupling获得
    bridge_findState.LoadList = {};
    bridge_findState.ConstraintList(obj.Params.index_CableConstraint) = []; % obj.Params.index_CableConstraint通过重载的addConstraint获得

    % 将梁重平均分配到Hanger和StayedCable上
    P_z_i = InitPz(obj,hanger_list,stayedcable_list);
    % 集中荷载代替斜拉索作用: 作用在梁上、塔上
    for i=1:length(stayedcable_list)
        stayedcable_i = stayedcable_list{i};
        P_z = ones(1,length(stayedcable_i.Line))*P_z_i;
        [load_cable_cell_i,load_girder_cell_i] = useLoadInsteadOfStayedCable(stayedcable_i,P_z);
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
        P_z = ones(1,length(hanger_i.Line))*P_z_i;
        load_girder_cell_i = useLoadInsteadOfHanger(hanger_i,P_z);
        for j=1:3
            bridge_findState.addLoad(load_girder_cell_i{j})
        end
    end
    
    % 
end
function cloned_bridge = cloneBridge(BridgeObj)
    cloned_bridge = BridgeObj.empty;
    cloned_bridge(1).Params = struct;
    metaobj_from = metaclass(BridgeObj);
    props_from = {metaobj_from.PropertyList.Name};
    for i=1:length(props_from)
        cloned_bridge.(props_from{i}) = BridgeObj.(props_from{i});
    end
end
function [load_tower,load_girder] = useLoadInsteadOfStayedCable(stayedcable,P_z)
    % 输入：
    %   stayedcable: 一个StayedCable对象
    %   P_z: 数值向量；P_z(i) 对应 stayedcable.Line(i)
    % 输出：
    %   load_tower: 3个Load对象组成的cell；表示替换StayedCable在桥塔上的集中荷载
    %   load_girder: 3个Load对象组成的cell；表示替换StayedCable在加劲梁上的集中荷载
    girder_point = stayedcable.findGirderPoint;
    tower_point = stayedcable.findTowerPoint;
    assignin("base","P_z",P_z)
    [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = stayedcable.getP(-abs(P_z));
    
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
function load_girder = useLoadInsteadOfHanger(hanger,P_z)
    % 输入：
    %   stayedcable: 一个StayedCable对象
    %   P_z: 数值向量；P_z(i) 对应 stayedcable.Line(i)
    % 输出：
    %   load_tower: 3个Load对象组成的cell；表示替换StayedCable在桥塔上的集中荷载
    %   load_girder: 3个Load对象组成的cell；表示替换StayedCable在加劲梁上的集中荷载
    girder_point = hanger.findGirderPoint;
    [~,~,~,P_girder_x,P_girder_y,P_girder_z] = hanger.getP(P_z);

    load_girder_x = ConcentratedForce(girder_point,'X',-P_girder_x);
    load_girder_y = ConcentratedForce(girder_point,'Y',-P_girder_y);
    load_girder_z = ConcentratedForce(girder_point,'Z',-P_girder_z);

    load_girder_x.Name = [hanger.Name,'_GirderForce_X'];
    load_girder_y.Name = [hanger.Name,'_GirderForce_Y'];
    load_girder_z.Name = [hanger.Name,'_GirderForce_Z'];

    load_girder = {load_girder_x,load_girder_y,load_girder_z};
end
function P_z = InitPz(BrigdeObj,HangerList,StayedCableList)
    % 计算梁的总重
    girder_list= BrigdeObj.findStructureByClass('Girder');
    weight_girder = zeros(1,length(girder_list));
    for i=1:length(girder_list)
        % 计算每一个Girder对象的总重
        girder_i = girder_list{i};
        length_list_i = girder_i.Line.DeltaLength;
        Area_list_i = girder_i.Section.Area;
        gamma_i = girder_i.Material.MaterialData.gamma;
        weight_girder(i) = sum(length_list_i.*Area_list_i*gamma_i);
    end
    overall_weight = sum(weight_girder);

    % 计算每一个Hanger和StayedCable平均分摊到的重量(直接平均分配)
    count_hanger = 0;
    count_stayedCable = 0;
    for i=1:length(HangerList)
        hanger = HangerList{i};
        count_hanger = count_hanger + length(hanger.Line);
    end
    for i=1:length(StayedCableList)
        stayecable = StayedCableList{i};
        count_stayedCable = count_stayedCable + length(stayecable.Line);
    end
    
    P_z = overall_weight/(sum(count_stayedCable+count_hanger));
end