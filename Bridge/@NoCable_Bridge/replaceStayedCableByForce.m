function Load_StayedCableForce = replaceStayedCableByForce(obj,X,Pz_StayedCable)
    % 输入：
    %   X: Pz_StayedCable对应的作用位置
    %   Pz_StayedCable: 作用在加劲梁上的吊索索力竖向分力
    % 输出：
    %   Load_StayedCableForce: Load对象
    stayedcables = obj.ReplacedStayedCable;
    len_stayedcable = length(stayedcables);
    count_stayedcable = 0;
    for i=1:len_stayedcable
        count_stayedcable = count_stayedcable + length(stayedcables(i).Line);
    end

    % 获取各个位置的受力的数据
    ForceTowerX = zeros(1,count_stayedcable);
    ForceTowerY = zeros(1,count_stayedcable);
    ForceTowerZ = zeros(1,count_stayedcable);
    ForceGirderX = zeros(1,count_stayedcable);
    ForceGirderY = zeros(1,count_stayedcable);
    ForceGirderZ = zeros(1,count_stayedcable);
    TowerPoints = Point.empty;
    TowerPoints(1,count_stayedcable).Num = [];
    GirderPoints = Point.empty;
    GirderPoints(1,count_stayedcable).Num = [];
    flag = 1;
    for i=1:len_stayedcable
        stayedcable = stayedcables(i);
        Pz_girder = obj.getGirderPz(stayedcable,X,Pz_StayedCable);
        [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = stayedcable.getP(Pz_girder);
        tower_point = stayedcable.findTowerPoint;
        girder_point = stayedcable.findGirderPoint;
        TowerPoints(flag:flag+length(tower_point)-1) = tower_point;
        GirderPoints(flag:flag+length(girder_point)-1) = girder_point;

        ForceTowerX(flag:flag+length(tower_point)-1) = -P_tower_x;
        ForceTowerY(flag:flag+length(tower_point)-1) = -P_tower_y;
        ForceTowerZ(flag:flag+length(tower_point)-1) = -P_tower_z;
        ForceGirderX(flag:flag+length(girder_point)-1) = -P_girder_x;
        ForceGirderY(flag:flag+length(girder_point)-1) = -P_girder_y;
        ForceGirderZ(flag:flag+length(girder_point)-1) = -P_girder_z;
        flag = flag + length(girder_point);
    end

    % 创建Girder荷载的Load对象
    load_girder_x = ConcentratedForce(GirderPoints,'X',ForceGirderX);
    load_girder_y = ConcentratedForce(GirderPoints,'Y',ForceGirderY);
    load_girder_z = ConcentratedForce(GirderPoints,'Z',ForceGirderZ);
    load_girder_x.Name = 'StayedCable_GirderForce_X';
    load_girder_y.Name = 'StayedCable_GirderForce_Y';
    load_girder_z.Name = 'StayedCable_GirderForce_Z';

    % 创建Tower荷载的Load对象，需要合并作用在同一点处的
    tower_points = TowerPoints.unique;
    all_applied_value_x = zeros(1,length(tower_points));
    all_applied_value_y = zeros(1,length(tower_points));
    all_applied_value_z = zeros(1,length(tower_points));
    for i=1:length(tower_points)
        index = tower_points(i)==TowerPoints;
        all_applied_value_x(i) = sum(ForceTowerX(index));
        all_applied_value_y(i) = sum(ForceTowerY(index));
        all_applied_value_z(i) = sum(ForceTowerZ(index));
    end
    load_tower_x = ConcentratedForce(tower_points,'X',all_applied_value_x);
    load_tower_y = ConcentratedForce(tower_points,'Y',all_applied_value_y);
    load_tower_z = ConcentratedForce(tower_points,'Z',all_applied_value_z);
    load_tower_x.Name = 'StayedCable_TowerForce_X';
    load_tower_y.Name = 'StayedCable_TowerForce_Y';
    load_tower_z.Name = 'StayedCable_TowerForce_Z';

    % 汇总
    Load_StayedCableForce = {load_girder_x,load_girder_y,load_girder_z,load_tower_x,load_tower_y,load_tower_z};
end