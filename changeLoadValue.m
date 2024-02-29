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
