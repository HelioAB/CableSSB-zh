function Load_CableForce = replaceCableByForce(obj,X_Hanger,Pz_Hanger)
    % 输入：
    %   X_Hanger: Pz_Hanger对应的作用位置
    %   Pz_Hanger: 作用在加劲梁上的吊索索力竖向分力
    % 输出：
    %   Load_CableForce: Load对象

    % 主缆塔顶力
    tower_point = findCableForcePointOnTower(obj);
    Load_CableTowerForce_X = ConcentratedForce(tower_point,'X',zeros(1,length(tower_point)));
    Load_CableTowerForce_Y = ConcentratedForce(tower_point,'Y',zeros(1,length(tower_point)));
    Load_CableTowerForce_Z = ConcentratedForce(tower_point,'Z',zeros(1,length(tower_point)));

    % 主缆锚碇力
    girder_point = findCableForcePointOnGirder(obj);
    Load_CableGirderForce_X = ConcentratedForce(girder_point,'X',zeros(1,length(girder_point)));
    Load_CableGirderForce_Y = ConcentratedForce(girder_point,'Y',zeros(1,length(girder_point)));
    Load_CableGirderForce_Z = ConcentratedForce(girder_point,'Z',zeros(1,length(girder_point)));

    Load_CableForce = [Load_CableTowerForce_X,Load_CableTowerForce_Y,Load_CableTowerForce_Z,Load_CableGirderForce_X,Load_CableGirderForce_Y,Load_CableGirderForce_Z];
end
function girder_point = findCableForcePointOnGirder(obj) % 找点
end
function tower_point = findCableForcePointOnTower(obj) % 找点
end