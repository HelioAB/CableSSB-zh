function merge(obj,tolerance)
    arguments
        obj (1,:)
        tolerance {mustBeNumeric} = 1e-5
    end
    line = [obj.Line];
    line.merge(tolerance);
end