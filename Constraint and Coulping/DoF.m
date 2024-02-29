classdef DoF
    enumeration
        Ux
        Uy
        Uz
        Rotx
        Roty
        Rotz
    end
    methods
        function name_cell = Name(obj)
            name_cell = cell(1,length(obj));
            for i=1:length(obj)
                name_cell{i} = char(obj(i));
            end
        end
        function index = getIndex(obj)
            % 输入一个DoF对象数组，输出double类型的索引（不是logical类型）
            % obj = [Ux,Ux,Uz,Rotx], 则 [1,1,3,4] == obj.getIndex
            index = zeros(1,length(obj));
            for i=1:length(obj)
                switch obj(i)
                    case DoF.Ux
                        index(i) = 1;
                    case DoF.Uy
                        index(i) = 2;
                    case DoF.Uz
                        index(i) = 3;
                    case DoF.Rotx
                        index(i) = 4;
                    case DoF.Roty
                        index(i) = 5;
                    case DoF.Rotz
                        index(i) = 6;
                end
            end
        end
    end
    methods(Static)
        function obj_list = All()
            obj_list = enumeration(DoF.empty)';
        end
        function obj_list = Uxyz()
            obj_list = [DoF.Ux,DoF.Uy,DoF.Uz];
        end
        function obj_list = Rxyz()
            obj_list = [DoF.Rotx,DoF.Roty,DoF.Rotz];
        end
    end
end