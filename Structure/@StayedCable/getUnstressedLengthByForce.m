function unstressed_length = getUnstressedLengthByForce(obj,P_tower_z)
    % P_tower_z：斜拉索上端z向受力 = -斜拉索上端对桥塔的z向施力,P_tower_z的符号满足全局坐标系
    % 斜拉索受拉时：P_z>0, 上端z向受力>0, 上端对桥塔的z向施力<0
    line = obj.Line;
    stressed_length = line.LineLength; % 有应力长度
    [~,~,delta_z] = line.DeltaLength;
    A = obj.Section.Area;
    w = obj.Material.MaterialData.gamma .* A; % 每延米自重
    E = obj.Material.MaterialData.E;

    unstressed_length = stressed_length ./ (1+(P_tower_z-0.5.*w.*stressed_length)./(abs(delta_z)./stressed_length.*E.*A));
end