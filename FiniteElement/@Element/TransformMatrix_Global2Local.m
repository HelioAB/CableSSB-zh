function T = TransformMatrix_Global2Local(obj,tol)
    % 坐标变换矩阵T将整体坐标系变化为局部坐标系，即
    % T: Global_Coord -> Local_Coord
    % 其逆变换为T的转置矩阵，即： inv(T) = T'
    arguments
        obj (1,1) % Element对象数组不要使用本方法，本方法仅适用于单个Element对象
        tol = 1e-5
    end
    if isempty(obj.TransformMatrix) % obj.TransformMatrix为空时才进行一次计算
        % 局部坐标系方向, 参考obj.getLocalCoordSystem,这里写它的一个element模式
        inode = obj.INode;
        jnode = obj.JNode;
        knode = obj.KNode;
        Vector_x = inode.Coord - jnode.Coord;
        if isempty(knode)
            Vector_y = cross([0,0,1],Vector_x);
            if dot(Vector_y,Vector_y) <= tol^2
                Vector_y = [0,1,0];
            end
        else
            Vector_IK = knode.Coord - inode.Coord;
            Vector_y = cross(Vector_IK,Vector_x);
            if dot(Vector_y,Vector_y) <= tol^2
                Vector_y = [0,1,0];
            end
        end
        Vector_z = cross(Vector_x,Vector_y);
        Norm_x = Vector_x/norm(Vector_x);
        Norm_y = Vector_y/norm(Vector_y);
        Norm_z = Vector_z/norm(Vector_z);
        % 坐标变换矩阵
        lambda = [Norm_x(1),Norm_x(2),Norm_x(3);
                  Norm_y(1),Norm_y(2),Norm_y(3);
                  Norm_z(1),Norm_z(2),Norm_z(3)];
        zeros_three = zeros(3,3);
        T = [lambda,zeros_three,zeros_three,zeros_three;
             zeros_three,lambda,zeros_three,zeros_three;
             zeros_three,zeros_three,lambda,zeros_three;
             zeros_three,zeros_three,zeros_three,lambda];
        obj.TransformMatrix = T;
    else % 否则使用存储值
        T = obj.TransformMatrix;
    end
end