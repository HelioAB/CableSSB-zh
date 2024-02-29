classdef Link10 < ElementType
    properties

    end
    methods
        function obj = Link10()
            obj@ElementType()
            obj.Name = 'Link10';
        end
        function Matrix = StiffnessMatrix(obj)
            warning('还未实现单元刚度矩阵，请用其他办法获得')
        end
        function output_str = outputElementType(obj,num_ET)
            output_str = [sprintf(['et,%d,Link10 \n' ...
                                  'keyopt,%d,2,2 \n' ...
                                  'keyopt,%d,3,0' ],num_ET,num_ET,num_ET),newline];
        end
        function output_str = outputReal(obj,Num,Area,Init_strain)
            len = length(Num);

            % 编号的向量长度应该和面积、初应变的向量长度相同，允许Area的长度为1
            % Num、Area、Init_strain均为数值向量
            if len~=length(Area)
                if length(Area) == 1 % Area的长度为1时
                    Area = zeros(1,length(Num)) + Area;
                else
                    error('输入的编号的向量长度应该和面积的向量长度相同，或面积的向量长度为1')
                end
            elseif length(Num)~=length(Init_strain)
                error('输入的编号的向量长度应该和初应变的向量长度相同')
            end
            
            % 输出字符串
            output_str = '';
            % 实常数
            for i=1:len
                output_str = strcat(output_str,sprintf('r,%d,%.6e,%.6e \n',Num(i),Area(i),Init_strain(i)));
            end
           
        end
    end
end