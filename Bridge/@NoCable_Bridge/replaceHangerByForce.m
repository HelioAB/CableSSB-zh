function Load_HangerForce = replaceHangerByForce(obj,X,Pz_Hanger)
    % 输入：
    %   X: Pz_Hanger对应的作用位置
    %   Pz_Hanger: 作用在加劲梁上的吊索索力竖向分力
    % 输出：
    %   Load_HangerForce: Load对象
    hangers = obj.ReplacedHanger;
    len_hanger = length(hangers);
    Load_HangerForce = cell(1,3*len_hanger);
    for i=1:len_hanger
        hanger = hangers(i);
        Pz_girder = obj.getGirderPz(hanger,X,Pz_Hanger);
        [~,~,~,P_girder_x,P_girder_y,P_girder_z] = hanger.getP(Pz_girder);
        girder_point = hanger.findGirderPoint;
        
        load_girder_x = ConcentratedForce(girder_point,'X',-P_girder_x);
        load_girder_y = ConcentratedForce(girder_point,'Y',-P_girder_y);
        load_girder_z = ConcentratedForce(girder_point,'Z',-P_girder_z);
    
        load_girder_x.Name = [hanger.Name,'_GirderForce_X'];
        load_girder_y.Name = [hanger.Name,'_GirderForce_Y'];
        load_girder_z.Name = [hanger.Name,'_GirderForce_Z'];
    
        Load_HangerForce(1,(i-1)*3+1:(i)*3) = {load_girder_x,load_girder_y,load_girder_z};
    end
end