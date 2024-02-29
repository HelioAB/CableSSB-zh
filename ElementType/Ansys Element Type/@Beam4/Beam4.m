classdef Beam4 < ElementType
    properties

    end
    methods
        function obj = Beam4()
            obj@ElementType()
            obj.Name = 'Beam4';
        end
        function Matrix = StiffnessMatrix(obj)
            warning('还未实现单元刚度矩阵，请用其他办法获得')
        end
        output_str = outputReal(obj,Num,Sec)
    end
end