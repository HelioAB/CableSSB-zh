function unstressed_length = getUnstressedLengthByForce(obj,P_cable_z)
    % P_z：吊杆上端z向受力 = -吊杆上端对桥塔的z向施力
    % 吊杆受拉时：P_z>0, 上端z向受力>0, 上端对桥塔的z向施力<0
    line = obj.Line;
    stressed_length = line.LineLength; % 有应力长度
    [~,~,delta_z] = line.DeltaLength;
    A = obj.Section.Area;
    w = obj.Material.MaterialData.gamma .* A; % 每延米自重
    E = obj.Material.MaterialData.E;

    unstressed_length = stressed_length ./ (1+(P_cable_z-0.5.*w.*stressed_length)./(abs(delta_z)./stressed_length.*E.*A));
end