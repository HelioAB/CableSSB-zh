function [Norm_x,Norm_y,Norm_z] = getLocalCoordSystem(obj,tol)
    % 使用Ansys中单元坐标系的方法定义Element的方向，具体方式见 https://www.yuque.com/helios-library/qgtem0/pmwbef
    arguments
        obj
        tol = 1e-5 % 两个向量相等的判断依据
    end
    inode = [obj.INode];
    jnode = [obj.JNode];
    knode = {obj.KNode};
    Vector_x = [jnode.Coord] - [inode.Coord];
    Norm_x = zeros(size(Vector_x));
    Norm_y = zeros(size(Vector_x));
    Norm_z = zeros(size(Vector_x));
    sz = size(Vector_x);
    for i=1:sz(1)
        % x轴方向始终为 INode到JNode
        vec_x = Vector_x(i,:);
        % z轴方向和y轴方向根据是否设置K点决定
        if isempty(knode{i})
            vec_y = cross([0,0,1],vec_x); % vec_y = (0,0,1) × vec_x
            if dot(vec_y,vec_y) <= tol^2 % vec_x == vec_z时
                vec_y = [0,1,0]; % 设置vec_y = [0,1,0],
            end
        else
            vec_IK = knode{i}.Coord - inode(i).Coord;
            vec_y = cross(vec_IK,vec_x); 
            if dot(vec_y,vec_y) <= tol^2 % vec_x == vec_z时
                vec_y = [0,1,0]; % 设置vec_y = [0,1,0],
            end
        end
        vec_z = cross(vec_x,vec_y); % vec_z = vec_x × vec_y
        Norm_x(i,:) = vec_x/norm(vec_x);
        Norm_y(i,:) = vec_y/norm(vec_y);
        Norm_z(i,:) = vec_z/norm(vec_z);
    end
end