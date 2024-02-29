classdef MinBendingStrainEnergy < OptimizationAlgorithm
    methods
        function obj = MinBendingStrainEnergy(ObjFunction,x0,A,b,Aeq,beq,lu,ub,NonlinearControl,AlgoHandle)
            options = optimoptions('fmincon','Display','iter','DiffMinChange',1e3,'MaxFunctionEvaluations',(length(x0)+1)*100); % 最小步长设置为1kN,每次优化有进行100个迭代
            obj = obj@OptimizationAlgorithm(ObjFunction,x0,A,b,Aeq,beq,lu,ub,NonlinearControl,AlgoHandle,options)
        end 
    end
end