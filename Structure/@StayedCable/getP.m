function [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = getP(obj,P_girder_z)
    % 输入：P_girder_z: 斜拉索下端（梁端）的竖向受力，向z正方向为正。通常情况符号为负号，表示斜拉索受拉
    % 输出：斜拉索的受力，z正方向为正
    % 输入输出均为StayedCable的受力，符号满足整体坐标系符号

    w = obj.Material.MaterialData.gamma .* obj.Section.Area; % 每延米自重
    P_tower_z_k = -P_girder_z;
    [delta_x,delta_y,delta_z] = obj.Line.DeltaLength;

    [~,sign_tower_tension] = obj.getStayedCableTensionDirectionAtTower();
    sign_girder_tension = -sign_tower_tension;

    P_girder_z = abs(P_girder_z) .* sign_girder_tension(:,3)';% 可以检查输入的P_girder_z与输出的P_girder_z是否负号一致，来检查本函数输出的符号正确性
    P_w_k = -w .* obj.getUnstressedLengthByForce(P_tower_z_k);
    P_girder_y = abs((P_girder_z + P_w_k/2) .* delta_y ./ delta_z) .* sign_tower_tension(:,2)';
    P_girder_x = abs((P_girder_z + P_w_k/2) .* delta_x ./ delta_z) .* sign_tower_tension(:,1)';

    P_tower_z = abs(P_girder_z + P_w_k) .* sign_tower_tension(:,3)';
    P_tower_y = -P_girder_y;
    P_tower_x = -P_girder_x;
    
    obj.InternalForce = sqrt((P_girder_x).^2 + (P_girder_y).^2 + (P_girder_z + P_w_k/2).^2);
    obj.UnstressedLength = obj.getUnstressedLengthByForce(P_tower_z);
    obj.Strain = obj.getStrain;
    obj.Params.P_girder_x = P_girder_x;% 存储StayedCable在梁端的受力
    obj.Params.P_girder_y = P_girder_y;
    obj.Params.P_girder_z = P_girder_z;
    obj.Params.P_tower_x = P_tower_x;% 存储StayedCable在主缆端的受力
    obj.Params.P_tower_y = P_tower_y;
    obj.Params.P_tower_z = P_tower_z;
end