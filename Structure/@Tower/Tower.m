classdef Tower < Structure
    properties
        Method_Creating
        RigidBeam
    end
    methods
        function obj = Tower(coord_bottom,coord_top,L,section,material)
            arguments
                coord_bottom (1,3) {mustBeNumeric} = [0,0,0] % 桥塔底端的坐标。
                coord_top (1,3) {mustBeNumeric} = [0,0,0] % 桥塔顶端的坐标。
                L (1,:) {mustBeNumeric} = 0 % 桥塔每个分段的竖向投影长度。如果coord_bottom > coord_top，L则为负
                section = Section('Tower')
                material = Material('Tower')
            end
            obj = obj@Structure(section,material);

            if abs(coord_top(3) - coord_bottom(3) - sum(L)) > eps
                warning('Tower的上下端点间的Z向距离不等于每个分段之和，请检查')
            end
            if nargin ~= 0 
                % 创建并记录Point和Line
                x_b = coord_bottom(1); % 底点顺桥向坐标
                x_t = coord_top(1); % 顶点顺桥向坐标
                y_b = coord_bottom(2); % 底点横桥向坐标
                y_t = coord_top(2); % 顶点横桥向坐标
                z_b = coord_bottom(3); % 底点高程
                z_t = coord_top(3); % 顶点高程
                X = createLinearArray(x_b,x_t,L);
                Y = createLinearArray(y_b,y_t,L);
                Z = createLinearArray(z_b,z_t,L);
                newpoint = Point([],X,Y,Z);
                if length(L)>=2
                    obj.Line = Line([],newpoint(1:end-1),newpoint(2:end));
                else
                    obj.Line = Line([],newpoint(1),newpoint(2));
                end
                obj.NewPoint = newpoint;
                obj.NewLine = obj.Line.findUnrecord();
            end
        end
        function set.Method_Creating(obj,val)
            if isa(val,'InputFrom')
                obj.Method_Creating = val;
            elseif isa(val,'function_handle') && isempty(obj.Method_Creating)
                obj.Method_Creating = InputFrom();
                obj.Method_Creating.AlgoHandle = val;
            elseif isa(val,'function_handle') && ~isempty(obj.Method_Creating)
                obj.Method_Creating.AlgoHandle = val;
            else
                error('请输入function_handle对象或InputFrom对象')
            end
        end
        function set.RigidBeam(obj,val)
            if isa(val,'RigidBeam')
                obj.RigidBeam = val;
            elseif ~isempty(val)
                error('设置RigidBeam时，请设置为RigidBeam对象')
            else
                obj.RigidBeam = [];
            end
        end
        function point = getPoint(obj)
            if isempty(obj.Line)
                point = [];
            else
                uni_point = unique([obj.Line.IPoint,obj.Line.JPoint]);
                point = uni_point.sort('Z');% obj.Point的顺序, 按照Point.Z排序
            end
        end
        create(obj)
        point_bottom = PointBottom(obj)% PointBottom和PointTop仅在仅有一条线时成立
        point_top = PointTop(obj)
    end
end
function array = createLinearArray(from,to,L)
    len = length(L);
    array = zeros(1,len+1);
    array(1) = from;
    array(end) = to;
    magnifier = (to-from)/sum(L);
    for i=1:len
        array(i+1) = array(i)+L(i)*magnifier;
    end
end