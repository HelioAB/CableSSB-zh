function symmetrize(obj,symmetric_point,normal_vector_direction)
    arguments
        obj
        symmetric_point (1,3) {mustBeNumeric}
        normal_vector_direction (1,3) {mustBeNumeric}
    end
    SymmPoint = symmetric_point;
    NormVecDir = normal_vector_direction;
    A = NormVecDir(1);
    B = NormVecDir(2);
    C = NormVecDir(3);
    D = -NormVecDir*SymmPoint';
    x = [obj.X];
    y = [obj.Y];
    z = [obj.Z];
    temp = (A*x+B*y+C*z+D)/(NormVecDir*NormVecDir');
    symm_X = x - 2*A*temp;
    symm_Y = y - 2*B*temp;
    symm_Z = z - 2*C*temp;
    len = length([obj.Num]);
    for i=1:len
        obj(1,i).X = symm_X(1,i);
        obj(1,i).Y = symm_Y(1,i);
        obj(1,i).Z = symm_Z(1,i);
    end
end