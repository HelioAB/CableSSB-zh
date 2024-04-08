classdef Structure < dynamicprops
    properties
        % 关于这个Structure对象本身的属性
        Point
        Line
        Section
        Material
        ElementType
        ElementDivisionNum = 1
        Params
        NewPoint
        NewLine

        % 关于这个Structure对象与其他Structure对象有什么关系，处于什么位置
        ForcePoint % Point属性当中，受外力（不包括ConnectPoint）非零的点，Point对象
        ConnectPoint_Table = {}
        
        % 信息
        Name
        Description
    end
    properties(Hidden)% 以下属性的设置很有局限性，是为了完成不得已需要的一些参数，根源在于程序设计的重大缺陷： 没有.clone后对象与原对象之间的变换关系和对应关系
        RelatedToStructure = []
    end
    properties(Hidden,Dependent)
        Index_Force % logical类型，是关于Point的索引
    end
    properties(Hidden,Constant)
        g  = 9.806
        dir_gravity = [0,0,-1] % 重力的方向向量
        dir_longitude = [1,0,0] % 顺桥向 方向向量
        dir_transverse = [0,1,0] % 横桥向 方向向量
        unit = struct('length','m','force','kN')
        compare_tolerance = 1e-5 % 比较两个数是否相等的容差
        X_axis_color = 'r'
        Y_axis_color = 'g'
        Z_axis_color = 'b'
    end

    methods
        function obj = Structure(section,material,options)
            arguments
                section {mustBeOfClass(section,'Section')} = Section().empty% 结构的截面参数，必须是Section对象
                material {mustBeOfClass(material,'Material')} = Material().empty% 结构的材料参数，必须是Material对象
                options.Name {mustBeText} = ''
            end
            % obj.Point通过obj.Line实时计算
            
            obj.Section = section;
            obj.Material = material;
            obj.Params = struct;
            if ~isempty(options.Name)
                obj.Name = options.Name;
            end
            % obj.NewPoint和obj.NewLine在尝试obj.record()时才会被计算
            % 其record_flag属性为false的Point对象或Line对象，才会被认为是NewPoint或NewLine
            if length(section) ~= 1 && length(obj.Line)~=length(section) && ~isempty(obj.Line)
                error('输入的section对象要么和obj.Line长度相同，要么长度为1')
            end
            if length(material) ~= 1 && length(obj.Line)~=length(material) && ~isempty(obj.Line)
                error('输入的material对象要么和obj.Line长度相同，要么长度为1')
            end

            obj.ForcePoint = Point().empty; % 必须要使用Point.empty因为obj.clone()里面需要用到
        end
        function val = get.Point(obj)
            val = obj.getPoint;
        end
        function val = getPoint(obj)
            % 如果需要其他排序方式，可以在子类中重载
            if isempty(obj.Line)
                val = [];
            else
                val = unique([obj.Line.IPoint,obj.Line.JPoint]); % obj.Point的顺序, 按照Point.Num排序
            end
        end
        function ForceIndex = get.Index_Force(obj)
            point = obj.Point;
            ForceIndex = false(1,length(point));
            Force_Point = obj.ForcePoint;
            if ~isempty(Force_Point)
                for i=1:length(Force_Point)
                    ForceIndex = ForceIndex | (Force_Point(i)==point);
                end
            end
        end

        function sec = get.Section(obj)
            sec = obj.getSection(obj.Section);
        end
        function sec = getSection(obj,section)
            len = length(obj.Line); % 因为在get.Section里面不能使用obj.Line，所以需要单独开一个成员方法来使用obj.Line
            if len == 0
                sec = Section().empty;
            else
                % 转换不同长度的Section对象数组为与Line相同长度的对象数组
                if length(section) == 0
                    sec = Section().empty;
                elseif length(section) == 1
                    sec(1,len) = section;
                    for i=1:len
                        sec(i) = section;
                    end
                elseif length(section) == len
                    sec = section;
                else
                    error('')
                end
            end
        end
        function set.ElementType(obj,val)
            % 设置不同的Structure使用不同的单元类型
            obj.ElementType = obj.setElementType(val);
        end
        function element_type = setElementType(obj,val)
            element_type = val;
        end 

        addConnectPoint(obj,ConnectPoint,StructureObj)
        deleteConnectPoint(obj,StructureObj)
        editConnectStructure(obj,FromStructure,ToStructure)
        StructureObj = showConnectStructure(obj)
        Connect_Point = ConnectPoint(obj,StructureObj)
        ConnectIndex = Index_Connect(obj,StructureObj)
        record(obj)
        unrecord(obj)
        delete(obj)
        setForcePoint(obj,Num)
        [P_x,P_y,P_z] = P(obj,Num_ForcePoint,P_force_x,P_force_y,P_force_z)
        num = PointNum2Num(obj,Num)% 可能会在子类中比重载
        translate(obj,difference)
        move(obj,RefPoint,Coord_MoveTo)
        [point_handle,line_handle] = plot(obj,options)
        newobj = clone(obj,options)
        copied_forcepoint = copyForcePoint(obj,ToObj)
        copied_connectpoint = copyConnectPoint(obj)
        symmetrize(obj,symmetric_point,normal_vector_direction)
        modifyPropertiesWhenSymmetrizing(obj)
        num = PointNum(obj)
        num = LineNum(obj)
        num = NewPointNum(obj)
        merge(obj,tolerance)
        point_list = findPoint(obj,SearchingMethod,Component,Direction,ByValue)
        index = findPointIndex(obj,points)
        line_list = findLineByCenterCoord(obj,component,direction)
        structure_list = findConnectStructureByClass(obj,class_name)
        [Norm_x,Norm_y,Norm_z]=getElementSystem(obj,tol)
        system_handle = plotElementSystem(obj,tol,options)
    end


    methods(Static)
        function [common_props,FromObj_special_props] = copyProperties(FromObj,ToObj,SpecialCopyProps,SpecialCopyMethod)
            arguments
                FromObj {mustBeA(FromObj,'Structure')}
                ToObj {mustBeA(ToObj,'Structure')}
                SpecialCopyProps {mustBeA(SpecialCopyProps,'cell')}
                SpecialCopyMethod {mustBeA(SpecialCopyMethod,'cell'),mustBeEqualSize(SpecialCopyProps,SpecialCopyMethod)} 
                % 每个function_handle都要求：
                % 1. 不需要额外的任何输入。如果需要2个输入a和b，可以@()function_handle(a,b)。
                %    相当于给function_handle设置默认值a,b，@符号后面的空括号相当于不用输入任何参数
                % 2. 仅输出copy后的对象
            end

            % 找到共有属性和特有属性，排除Constant,Hidden,Dependent的属性
            metaobj_from = metaclass(FromObj);
            metaobj_to = metaclass(ToObj);
            props_from = {metaobj_from.PropertyList.Name};
            props_to = {metaobj_to.PropertyList.Name};
            index_hidden_from = [metaobj_from.PropertyList.Hidden];
            index_hidden_to = [metaobj_to.PropertyList.Hidden];
            index_dependent_from = [metaobj_from.PropertyList.Dependent];
            index_dependent_to = [metaobj_to.PropertyList.Dependent];
            index_constant_from = [metaobj_from.PropertyList.Constant];
            index_constant_to = [metaobj_to.PropertyList.Constant];
            props_from_copy = props_from(~(index_hidden_from|index_dependent_from|index_constant_from));
            props_to_copy = props_to(~(index_hidden_to|index_dependent_to|index_constant_to));
            common_props = {}; % from和to共有的属性
            FromObj_special_props = {}; % from特有的属性
            for i = 1:length(props_from_copy)
                index = strcmp(props_from_copy{i},props_to_copy);
                if any(index)
                    common_props{end+1} = props_from_copy{i};
                else
                    FromObj_special_props{end+1} = props_from_copy{i};
                end
            end

            % 共有属性的复制
            for i=1:length(common_props)
                index_special_props = strcmp(common_props{i},SpecialCopyProps);
                if any(index_special_props) % 需要特殊copy方法的属性
                    copymethod = SpecialCopyMethod{index_special_props};
                    ToObj.(common_props{i}) = copymethod();
                else % 不用特殊copy方法的属性
                    ToObj.(common_props{i}) = FromObj.(common_props{i});
                end
            end
            % from特有属性的复制，需要使用dynamicprops.addprop方法
            if ~isempty(FromObj_special_props)
                for i=1:length(FromObj_special_props)
                    addprop(ToObj,FromObj_special_props{i}); % 添加属性
                    index_special_props = strcmp(FromObj_special_props{i},SpecialCopyProps);
                    if any(index_special_props) % 需要特殊copy方法的属性
                        copymethod = SpecialCopyMethod{index_special_props};
                        ToObj.(FromObj_special_props{i}) = copymethod();
                    else % 不用特殊copy方法的属性
                        ToObj.(FromObj_special_props{i}) = FromObj.(FromObj_special_props{i}); % 复制属性值
                    end
                end
            end
        end
        function system_handle = plotSystem(OriginCoord,Norm_x,Norm_y,Norm_z,options)
            arguments
                OriginCoord (:,3) {mustBeNumeric} % 坐标原点
                Norm_x (:,3) {mustBeNumeric,mustBeEqualSize(Norm_x,OriginCoord)} 
                Norm_y (:,3) {mustBeNumeric,mustBeEqualSize(Norm_y,OriginCoord)} 
                Norm_z (:,3) {mustBeNumeric,mustBeEqualSize(Norm_z,OriginCoord)} 
                options.Scale {mustBePositive} = 1.0 % 缩放倍数
                options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
                options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
            end

            start_X = OriginCoord(:,1)';
            start_Y = OriginCoord(:,2)';
            start_Z = OriginCoord(:,3)';

            delta_X_x = options.Scale*Norm_x(:,1)';
            delta_Y_x = options.Scale*Norm_x(:,2)';
            delta_Z_x = options.Scale*Norm_x(:,3)';

            delta_X_y = options.Scale*Norm_y(:,1)';
            delta_Y_y = options.Scale*Norm_y(:,2)';
            delta_Z_y = options.Scale*Norm_y(:,3)';

            delta_X_z = options.Scale*Norm_z(:,1)';
            delta_Y_z = options.Scale*Norm_z(:,2)';
            delta_Z_z = options.Scale*Norm_z(:,3)';
            
            figure(options.Figure)
            hold(options.Axis,'on')
            % x轴
            arrow_x = quiver3(options.Axis,start_X,start_Y,start_Z,delta_X_x,delta_Y_x,delta_Z_x,'off');
            arrow_x.Color = Structure.X_axis_color;
            arrow_x.MaxHeadSize  = 0.1;
            % y轴
            arrow_y = quiver3(options.Axis,start_X,start_Y,start_Z,delta_X_y,delta_Y_y,delta_Z_y,'off');
            arrow_y.Color = Structure.Y_axis_color;
            arrow_y.MaxHeadSize  = 0.1;
            % z轴
            arrow_z = quiver3(options.Axis,start_X,start_Y,start_Z,delta_X_z,delta_Y_z,delta_Z_z,'off');
            arrow_z.Color = Structure.Z_axis_color;
            arrow_z.MaxHeadSize  = 0.1;
            hold(options.Axis,'off')
            system_handle = [arrow_x,arrow_y,arrow_z];
        end

    end
end

function mustBeOfClass(input,className)
    if ~isa(input,className)
        eid = 'Class:notCorrectClass';
        msg = ['输入值必须为以下类型的子类：', className];
        throwAsCaller(MException(eid,msg))
    end
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end