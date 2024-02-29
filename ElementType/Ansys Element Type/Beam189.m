classdef Beam189 < ElementType
    properties
        AdditionalNode = 1 % 除了IJ节点之外，一个单元还有多少个积分节点，如果为0，则单元弯矩在两端相同；如果为1，单元弯矩为线性的
    end
    methods
        function obj = Beam189()
            obj@ElementType('Beam189')
        end
        function output_str = outputReal(obj)
            output_str = '';
        end
        function output_str = outputElementType(obj,num_ET)
            if obj.AdditionalNode==0
                output_str = [sprintf('et,%d,Beam189',num_ET),newline];
            elseif obj.AdditionalNode==1
                output_str = [sprintf(['et,%d,Beam189 \n',...
                                       'keyopt,%d,3,2'],num_ET,num_ET),newline];
            end
        end
        function Matrix = StiffnessMatrix(obj)
            warning('还未实现单元刚度矩阵，请用其他办法获得')
        end
    end
end