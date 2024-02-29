classdef ISection < SectionData
    properties
        % 下面的"上下"方位是指+z为上，-z为下
        Width_TopFlange % 上翼缘的宽度（两肢而不是一肢）
        Width_BottomFlange % 下翼缘的宽度
        Depth % 上翼缘端到下翼缘端之间的距离
        Thickness_TopFlange % 上翼缘的厚度
        Thickness_BottomFlange % 下翼缘的厚度
        Thickness_Web % 腹板厚度
    end
    methods
        function obj = ISection(W1,W2,W3,t1,t2,t3)
            arguments
                W1 (1,1) {mustBePositive}
                W2 (1,1) {mustBePositive}
                W3 (1,1) {mustBePositive}
                t1 (1,1) {mustBePositive}
                t2 (1,1) {mustBePositive}
                t3 (1,1) {mustBePositive}
            end
            obj = obj@SectionData('I-Beam')
            obj.Width_TopFlange = W1;
            obj.Width_BottomFlange = W2;
            obj.Depth = W3;
            obj.Thickness_TopFlange = t1;
            obj.Thickness_BottomFlange = t2;
            obj.Thickness_Web = t3;
        end
        A = Area(obj)
        output_str = OutputToAnsys(obj,sec_num)
    end
end