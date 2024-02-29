classdef CircleSection < SectionData
    properties
        Radius
    end
    methods
        function obj = CircleSection(Radius)
            arguments
                Radius (1,1) {mustBePositive}
            end
            obj = obj@SectionData('Solid Circle')
            obj.Radius = Radius;
        end
        A = Area(obj)
        output_str = OutputToAnsys(obj,sec_num)
    end
end