function [Norm_x,Norm_y,Norm_z]=getElementSystem(obj,tol)
    arguments
        obj
        tol = 1e-3 % 两个向量相等的判断依据
    end
    [Norm_x,Norm_y,Norm_z] = obj.Line.getDirection(tol);
end