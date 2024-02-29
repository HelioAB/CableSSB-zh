function [Comp_x,Comp_y,Comp_z] = getLocalCoordSystemComponent(obj,GlobalDirection,tol)
    %  给定一个大小和方向direction（1*3数值向量），获得在局部坐标系的各个分量
    arguments
        obj
        GlobalDirection (1,3)
        tol = 1e-5 % 两个向量相等的判断依据
    end
    [Norm_x,Norm_y,Norm_z] = obj.getLocalCoordSystem(tol);
    Comp_x = zeros(length(obj),1);
    Comp_y = zeros(length(obj),1);
    Comp_z = zeros(length(obj),1);
    for i=1:length(obj)
        Norm_x_i = Norm_x(i,:);
        Norm_y_i = Norm_y(i,:);
        Norm_z_i = Norm_z(i,:);
        Comp_x(i) = GlobalDirection*Norm_x_i';
        Comp_y(i) = GlobalDirection*Norm_y_i';
        Comp_z(i) = GlobalDirection*Norm_z_i';
    end
end