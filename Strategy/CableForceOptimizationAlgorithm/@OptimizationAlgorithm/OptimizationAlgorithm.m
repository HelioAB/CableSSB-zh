classdef OptimizationAlgorithm < Strategy
    properties
        % Strategy.AlgoHandle: 从Strategy类继承而来的属性，表示使用什么算法，默认为Matlab自带的优化函数 @fmincon，也可以使用遗传算法 @ga等
        RefObj % 存储优化时需要使用的对象
        Result % 存储优化过程中需要输出的结果
        ObjFunction
        x0
        A
        b
        Aeq
        beq
        lu
        ub
        NonlinearControl
        options
    end
    properties(Hidden)
        isOptimizing = false % 是否正在优化 
    end
    methods
        function obj = OptimizationAlgorithm(ObjFunction,x0,A,b,Aeq,beq,lu,ub,NonlinearControl,AlgoHandle,options)
            arguments
                ObjFunction {mustBeA(ObjFunction,'function_handle')}
                x0
                A = []
                b = []
                Aeq = []
                beq = []
                lu = []
                ub = []
                NonlinearControl {mustBeA(NonlinearControl,["function_handle","double"])} = []
                AlgoHandle = @fmincon % 默认使用fmincon作为优化函数
                options = optimoptions(func2str(AlgoHandle),'Display','iter')
            end
            obj.ObjFunction = ObjFunction;
            obj.x0 = x0;
            obj.A = A;
            obj.b = b;
            obj.Aeq = Aeq;
            obj.beq = beq;
            obj.lu = lu;
            obj.ub = ub;
            obj.NonlinearControl = NonlinearControl;
            obj.AlgoHandle = AlgoHandle;
            obj.options = options;
        end
        function action(obj)
            obj.AlgoHandle(obj.ObjFunction,obj.x0,obj.A,obj.b,obj.Aeq,obj.beq,obj.lu,obj.ub,obj.NonlinearControl,obj.AlgoHandle,obj.options)
        end
    end
end