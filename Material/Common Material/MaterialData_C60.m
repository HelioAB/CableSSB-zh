classdef MaterialData_C60 < LinkOrBeam
    methods
        function obj = MaterialData_C60()
            obj = obj@LinkOrBeam(...
                                3.6e10,...       % 弹性模量
                                0.2,...         % 泊松比
                                2.5e4,...          % 容重, N/m^3
                                1e-5)           % 线膨胀系数
            obj.MaterialType = 'C60';
        end
    end
end