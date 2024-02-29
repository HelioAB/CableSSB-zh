classdef TubeSection < SectionData
    properties
        Radius_Inner
        Radius_Outer
    end
    methods
        function obj = TubeSection(Radius_Inner,Radius_Outer)
            arguments
                Radius_Inner (1,1) {mustBePositive}
                Radius_Outer (1,1) {mustBePositive}
            end
            obj = obj@SectionData('Solid Circle')
            obj.Radius_Inner = Radius_Inner;
            obj.Radius_Outer = Radius_Outer;
        end
        A =Area(obj)
        output_str = OutputToAnsys(obj,sec_num)
    end
end