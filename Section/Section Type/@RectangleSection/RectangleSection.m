classdef RectangleSection < SectionData
    properties
        Width
        Height
    end
    methods
        function obj = RectangleSection(Width,Height)
            arguments
                Width (1,1) {mustBePositive}
                Height (1,1) {mustBePositive}
            end
            obj = obj@SectionData('Rectangle')
            obj.Width = Width;
            obj.Height = Height;
        end
        I = Iyy(obj)
        I = Izz(obj)
        A = Area(obj)
        output_str = OutputToAnsys(obj,sec_num)
    end
end