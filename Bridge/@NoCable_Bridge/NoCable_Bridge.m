classdef NoCable_Bridge < Bridge
    properties
        OriginalBridge
        FiniteElementModel
        % 注：前面带Replaced的Structure对象cell，代表被隐藏起来的。没有带Replaced的Structure对象cell，是可以被plot和output的
        % 其实应该把它们设置为private的属性，直接操作它们是不安全的，但是为了节约时间，这里不开发操作这些的方法
        % 梁塔系统
        ReplacedGirder
        ReplacedTower
        ReplacedRigidBeam
        ReplacedPier
        % 缆索系统
        ReplacedCable
        ReplacedHanger
        ReplacedStayedCable
        % 
        DeletedConstraint
        DeletedCoupling
        DeletedLoad = {}

        XCoordOfPz
    end
    properties % 迭代结果
        isOptimizing = false % 是否正在索力优化
        Iter_Optimization = 0 % 当前优化迭代次数
        Result_Iteration = struct % 最后的优化结果
    end
    methods
        function obj = NoCable_Bridge(bridge)
            obj = obj@Bridge;
            if nargin
                obj.OriginalBridge = bridge;
            end
        end
        build(obj)

        Load_HangerForce = replaceHangerByForce(obj,X,Pz_Hanger) % 吊索作用在主梁上的力
        Load_StayedCableForce = replaceStayedCableByForce(obj,X,Pz_StayedCable) % 斜拉索作用在主梁和桥塔上的力
        Load_CableForce = replaceCableByForce(obj,X,Pz_Hanger) % 自锚主缆力、桥塔主缆力
        replaceRHSByLoad(obj)

        [Pz_girder,index]= getGirderPz(obj,structure,X,Pz) % 根据X排列的Pz，输出structure.getP(*)可以直接使用的Pz
        [FEModel,isEquationCompleted] = getFiniteElementModel(obj) % 获取有限元模型（导出到Ansys，再导入回Matlab）
        Pz = getAverageGirderWeight(obj)
        optimBendingStrainEnergy(obj,options)
        OnlyCableBridge = getOnlyCableBridge(obj)
        
        Y_final = solveCableShape(obj,Pz,Y_0)
        xx_solveInitialStrain(obj)
        x_solveInitialStrain(obj)
        solveInitialStrain(obj)

        output_str = outputAnsysIPC(obj,num_elem)
    end
    methods(Static,Hidden) % 用于测试的函数
        test_PointForceVSNodeForce
        test_optim
    end
end