classdef CableStayed_Bridge < Bridge
    methods
        build(obj)
        bridge_findState = solveReasonableFinishedDeadState(obj)% 找成桥合理状态
    end
end