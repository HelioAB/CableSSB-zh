classdef MaterialData_RigidBeam < LinkOrBeam
    methods
        function obj = MaterialData_RigidBeam()
            obj = obj@LinkOrBeam(...
                                1e15,...        % 弹性模量
                                0.3,...         % 泊松比
                                0,...           % 容重, N/m^3
                                0)              % 线膨胀系数
            obj.MaterialType = 'Rigid Beam';
        end
    end
end