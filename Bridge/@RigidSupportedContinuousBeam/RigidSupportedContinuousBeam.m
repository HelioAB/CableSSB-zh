classdef RigidSupportedContinuousBeam < Bridge
    properties
        OriginalBridge
        FiniteElementModel
        % 注：前面带Replaced的Structure对象cell，代表被隐藏起来的。没有带Replaced的Structure对象cell，是可以被plot和output的
        % 其实应该把它们设置为private的属性，直接操作它们是不安全的，但是为了节约时间，这里不开发操作这些的方法
        % 梁塔系统
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
        SupportedPoint
    end
    methods
        function obj = RigidSupportedContinuousBeam(bridge)
            obj = obj@Bridge;
            if nargin
                obj.OriginalBridge = bridge;
            end
        end
        build(obj)
        % output(obj)
        Pz = getSupportedForce(obj)
    end

end