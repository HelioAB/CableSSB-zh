function obj = reverse(obj)
    if length(obj) > 1
        obj = obj(end:-1:1);
    end
end