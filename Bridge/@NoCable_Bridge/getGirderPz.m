function [Pz_girder,index]= getGirderPz(obj,structure,X,Pz)
    arguments
        obj
        structure {mustBeA(structure,["StayedCable","Hanger"])}
        X % Pz作用位置的X坐标
        Pz
    end
    % 输入按X排序的Pz，输出Structure可以直接使用的Pz
    % 例如：
    %   Pz_girder = getGirderPz(stayedcable,X,Pz);
    %   [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = stayedcable.getP(Pz_girder);
    X_girder_point = [];
    for i=1:length(structure)
        girder_point = structure(i).findGirderPoint;
        X_girder_point = [X_girder_point,girder_point.X];
    end
    Pz_girder = zeros(1,length(X_girder_point));
    index = false(1,length(X));
    for i=1:length(X)
        index_i = abs(X(i)-X_girder_point) < 1e-5;
        if any(index_i)
            index(i) = true;
        end
        Pz_girder(index_i) = Pz(i);
    end
end