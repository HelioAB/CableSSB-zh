classdef EmptyCable < Bridge
    methods
        % 空缆，用以验证找形算法的正确性
        build(obj)
        solveHangerTopCoord(obj,hanger) % 根据已知吊杆力，求解吊杆上端的空间位置（注意，固定竖向吊杆力时，不一定有解）
    end
end