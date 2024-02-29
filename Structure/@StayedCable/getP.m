function [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = getP(obj,P_girder_z)
    % 输入：P_girder_z: 斜拉索下端（梁端）的竖向受力，向z正方向为正。通常情况符号为负号，表示斜拉索受拉
    % 输出：斜拉索的受力，z正方向为正
    % 输入输出均为StayedCable的受力，符号满足整体坐标系符号

    w = obj.Material.MaterialData.gamma .* obj.Section.Area; % 每延米自重
    P_tower_z_k = -P_girder_z;
    eps = 0.005; % 可修改收敛误差
    iter_num = 100;
    iter_count = 0;
    err = 1;
    [delta_x,delta_y,delta_z] = obj.Line.DeltaLength;

    [~,sign_tower_tension] = obj.getStayedCableTensionDirectionAtTower();
    sign_girder_tension = -sign_tower_tension;

    P_girder_z = abs(P_girder_z) .* sign_girder_tension(:,3)';% 可以检查输入的P_girder_z与输出的P_girder_z是否负号一致，来检查本函数输出的符号正确性
    while err>eps
        unstressed_length = obj.getUnstressedLengthByForce(P_tower_z_k);
        P_w_k = -w.*unstressed_length;
        P_tower_z_k1 = -(P_girder_z + P_w_k);
        err = max((P_tower_z_k1-P_tower_z_k)./P_tower_z_k);
        P_tower_z_k = P_tower_z_k1;
        iter_count = iter_count+1;
        if iter_count>iter_num
            error('超出迭代次数限制')
        end
    end

    P_tower_z = abs(P_tower_z_k) .* sign_tower_tension(:,3)';
    P_tower_y = abs((P_w_k.*delta_y/2 + delta_y.*P_tower_z) ./ delta_z) .* sign_tower_tension(:,2)';
    P_tower_x = abs(P_tower_y .* delta_x ./ delta_y) .* sign_tower_tension(:,1)';
    
    P_girder_y = -P_tower_y;
    P_girder_x = -P_tower_x;
    
    obj.InternalForce = sqrt(((abs(P_girder_x)+abs(P_tower_x))./2).^2 + ((abs(P_girder_y)+abs(P_tower_y))./2).^2 + ((abs(P_girder_z)+abs(P_tower_z))./2).^2);
    obj.UnstressedLength = obj.getUnstressedLengthByForce(P_tower_z);
    obj.Strain = obj.getStrain;
    obj.Params.P_girder_x = P_girder_x;% 存储StayedCable在梁端的受力
    obj.Params.P_girder_y = P_girder_y;
    obj.Params.P_girder_z = P_girder_z;
    obj.Params.P_tower_x = P_tower_x;% 存储StayedCable在主缆端的受力
    obj.Params.P_tower_y = P_tower_y;
    obj.Params.P_tower_z = P_tower_z;
end