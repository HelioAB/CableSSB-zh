function kpoint = setKPoint(obj,X,Y,Z)
    arguments
        obj
        X (1,:) {mustBeNumeric}
        Y (1,:) {mustBeNumeric}
        Z (1,:) {mustBeNumeric}
    end
    if length(X) ~= length(Y)
        error('输入的X应与Y的向量长度相等')
    elseif length(X) ~= length(Z)
        error('输入的X应与Z的向量长度相等')
    end
    % KPoint设设置原则：
    %    1. 不能与IPoint和JPoint共线
    %    2. KPoint用来表示截面方向
    kpoint = Point([],X,Y,Z);
    lines = obj.Line;
    ipoints = [lines.IPoint];
    jpoints = [lines.JPoint];
    for i=1:length(lines)
        ipoint = ipoints(i);
        jpoint = jpoints(i);
        vec_ik = kpoint.Coord - ipoint.Coord;
        vec_jk = kpoint.Coord - jpoint.Coord;
        % 共点
        if norm(vec_ik) <= 1e-3 || norm(vec_jk) <= 1e-3
            continue
        end
        % 共线
        if norm(cross(vec_ik,vec_jk)) < 1e-3
            continue
        end
        % IJK点不共线
        lines(i).setKPoint(kpoint);
    end
    kpoint.record();
end