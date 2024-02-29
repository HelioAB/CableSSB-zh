classdef BoxSection < SectionData
    properties
        Width_Outer % 箱型截面外缘宽度
        Height_Outer % 箱型截面外缘高度
        Thickness_Web1 % 腹板(单元坐标系-y方向)的厚度
        Thickness_Web2 % 腹板(单元坐标系+y方向)的厚度
        Thickness_BottomBoard % 底板(单元坐标系-z方向)厚度
        Thickness_TopBoard % 顶板(单元坐标系+z方向)厚度
    end
    methods
        function obj = BoxSection(W1,W2,t1,t2,t3,t4)
            arguments
                W1 (1,1) {mustBePositive}
                W2 (1,1) {mustBePositive}
                t1 (1,1) {mustBePositive}
                t2 (1,1) {mustBePositive}
                t3 (1,1) {mustBePositive}
                t4 (1,1) {mustBePositive}
            end
            if W1-t1-t2<0
                error('箱型截面的外翼缘宽度应该大于横向腹板厚度之和')
            end
            if W2-t3-t4<0
                error('箱型截面的外翼缘高度应该大于竖向腹板厚度之和')
            end
            obj = obj@SectionData('Box-Beam')
            obj.Width_Outer = W1;
            obj.Height_Outer = W2;
            obj.Thickness_Web1 = t1;
            obj.Thickness_Web2 = t2;
            obj.Thickness_BottomBoard = t3;
            obj.Thickness_TopBoard = t4;
        end
        I = Iyy(obj)
        I = Izz(obj)
        A = Area(obj)
        output_str = OutputToAnsys(obj,sec_num)
    end
end