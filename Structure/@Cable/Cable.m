classdef Cable < Structure
    properties
        Algo_ShapeFinding
        Result_ShapeFinding
        UnstressedLength
        Strain
    end
    methods
        function obj = Cable(coord_A,coord_B,L,section,material)
            arguments
                coord_A (1,3) {mustBeNumeric} = [0,0,0] % 主缆端点A的坐标。主缆找形程序中的O_0点
                coord_B (1,3) {mustBeNumeric} = [0,0,0] % 主缆端点B的坐标。主缆找形程序中的O_n+1点
                L (1,:) {mustBeNumeric} = 0 % 主缆每个分段的顺桥向水平投影长度。如果coord_A > coord_B，L则为负
                section = Section('Cable')
                material = Material('Cable')
            end
            obj = obj@Structure(section,material);

            % 输入参数验证
            l_span = coord_B(1) - coord_A(1); % 跨径
            if ~(abs(l_span-sum(L)) <= Structure.compare_tolerance) % 跨径 与 L之和 差值小于容差
                error('顺桥向端点AB之间的坐标差值 与 每个分段的顺桥向水平投影长度之和 不等')
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
                
                % Params
                obj.Params.L = L;
                obj.Params.coord_A = coord_A;
                obj.Params.coord_B = coord_B;
                obj.Params.l_span = l_span;
                % 计算点数字相关
                n = length(L)-1;% 除两端点，主缆的分段计算点的数目
                if mod(n,2) == 1 % 跨中点对应的主缆分段计算节点编号，分奇偶讨论
                    m = (n+1)/2;
                elseif mod(n,2) == 0
                    m = n/2;
                end
                obj.Params.n = n;
                obj.Params.m = m;
            end
        end
        function set.Algo_ShapeFinding(obj,val)
            if isempty(val)
                obj.Algo_ShapeFinding = [];
            elseif isa(val,'ShapeFinding')
                obj.Algo_ShapeFinding = val;
            elseif isa(val,'function_handle') && isempty(obj.Algo_ShapeFinding)
            % 如果将Algo_ShapeFinding属性设置为函数句柄，那就新建一个ShapeFinding对象。
            % 然后这个ShapeFinding对象的Algo_handle属性设置为指定的函数句柄。
            % 外部调用Algo_ShapeFinding属性始终为ShapeFinding对象
                obj.Algo_ShapeFinding = ShapeFinding();
                obj.Algo_ShapeFinding.AlgoHandle = val;
            elseif isa(val,'function_handle') && ~isempty(obj.Algo_ShapeFinding)
                obj.Algo_ShapeFinding.AlgoHandle = val;
            else
                error('请输入function_handle对象或ShapeFinding对象')
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

        point_A = PointA(obj)
        point_B = PointB(obj)
        element_type = setElementType(obj,val)
        record(obj)
        newobj = clone(obj)
        Num = PointNum2Num(obj,Index)
        [P_x,P_y,P_z] = P(obj,Index_Hanger,P_hanger_x,P_hanger_y,P_hanger_z)
        Output  = findShape(obj,P_x,P_y,P_z)
        modifyPropertiesWhenSymmetrizing(obj)
        
        tower_points = findTowerPoint(obj)
        girder_points = findGirderPoint(obj)
        ground_point = findGroundPoint(obj)

        RelatedObj = resumeSymmetrical(obj)
        internal_force = InternalForce(obj)
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

