classdef Girder < Structure
    properties
        Method_Creating
        RigidBeam
    end
    methods
        function obj = Girder(coord_A,coord_B,L,section,material)
            arguments
                coord_A (1,3) {mustBeNumeric} = [0,0,0] % 主梁端点A的坐标。
                coord_B (1,3) {mustBeNumeric} = [0,0,0] % 主梁端点B的坐标。
                L (1,:) {mustBeNumeric} = 0 % 主梁每个分段的顺桥向水平投影长度。如果coord_A > coord_B，L则为负
                section = Section('Girder')
                material = Material('Girder')
            end
            obj = obj@Structure(section,material);
            
            if abs(coord_B(1) - coord_A(1) - sum(L)) > 1e-5
                warning('Girder的左右端点间的X向距离不等于每个分段之和，请检查')
            end
            if nargin ~= 0 
                % 创建并记录Point和Line
                x_A = coord_A(1); % A点顺桥向坐标
                x_B = coord_B(1); % B点顺桥向坐标
                y_A = coord_A(2); % A点横桥向坐标
                y_B = coord_B(2); % B点横桥向坐标
                z_A = coord_A(3); % A点高程
                z_B = coord_B(3); % B点高程
                X = createLinearArray(x_A,x_B,L);
                Y = createLinearArray(y_A,y_B,L);
                Z = createLinearArray(z_A,z_B,L);
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
            if isempty(val)
                obj.Method_Creating = [];
            elseif isa(val,'InputFrom')
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
            % RigidBeam很可能有多个
            if isa(val,'RigidBeam')
                obj.RigidBeam = val;
            elseif ~isempty(val)
                error('设置RigidBeam时，请设置为非空的RigidBeam对象')
            else
                obj.RigidBeam = [];
            end
        end
        function point = getPoint(obj)
            if isempty(obj.Line)
                point = [];
            else
                uni_point = unique([obj.Line.IPoint,obj.Line.JPoint]);
                point = uni_point.sort('X');% obj.Point的顺序, 按照Point.X排序
            end
        end

        create(obj)
        point_A = PointA(obj)% PointA和PointB仅在仅有一条线时成立
        point_B = PointB(obj)
        point_center = PointCenter(obj)% 跨中点
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