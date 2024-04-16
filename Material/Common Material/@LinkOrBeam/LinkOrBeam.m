classdef LinkOrBeam < MaterialData
    properties
        E % 弹性模量
        prxy % 泊松比
        gamma % 容重, N/m^3
        density % 密度, kg/m^3
        alpha_x % Coefficient of linear expansion线膨胀系数
        multi_grav = 1
    end
    methods
        function obj = LinkOrBeam(E,prxy,gamma,alpha_x)
            obj = obj@MaterialData('Link or Beam')
            obj.E = E;
            obj.prxy = prxy;
            obj.gamma = gamma;
            obj.density = gamma/9.806;
            obj.alpha_x = alpha_x;
        end
        function gamma = get.gamma(obj)
            gamma = obj.gamma * obj.multi_grav;
        end
        material_data_struct = outputToAnsys(obj)
    end
end