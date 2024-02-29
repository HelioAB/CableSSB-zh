function symmetrize(obj,symmetric_point,normal_vector_direction)
    arguments
        obj (1,1)
        symmetric_point (1,3) {mustBeNumeric} = [0,0,0]
        normal_vector_direction (1,3) {mustBeNumeric} = [0,1,0] % 默认以 0点为对称点，Y方向对称
    end
    obj.NewPoint.symmetrize(symmetric_point,normal_vector_direction);
    obj.modifyPropertiesWhenSymmetrizing;
end