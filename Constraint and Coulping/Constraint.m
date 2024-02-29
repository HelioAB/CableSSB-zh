classdef Constraint < DataRecord
    properties
        Name
        Point
        DoF
        Value
    end
    methods
        function obj = Constraint(point,dof,value)
            arguments
                point (1,1) {mustBeA(point,'Point')} = Point()
                dof (1,:) {mustBeText} = {'Ux','Uy','Uz','Rotx','Roty','Rotz'}
                value (1,:) {mustBeNumeric,mustBeEqualSize(dof,value)} = zeros(1,length(dof))
            end
            obj = obj@DataRecord();
            if nargin
                obj.Num = Constraint.MaxNum+1;
                obj.Name = '';
                obj.Point = point;
                obj.DoF = convertDoF(dof);
                obj.Value = value;
            end
        end
        function record(obj)
            if isempty([obj.Point])
                error('即将record的对象不存在Point对象作为其Constraint.Point属性的值')
            end
            record@DataRecord(obj);
        end
        function point_handle = plot(obj,S,C,options)
            arguments
                % 均为MATLAB中默认的参数值
                obj
                S = 36
                C = 'r'
                options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
                options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
            end
            % 其他参数通过访问对象point_handle的属性值修改
            point = [obj.Point];
            hold(options.Axis,'on')
            point_handle = point.plot(S,C,"Figure",options.Figure,"Axis",options.Axis);
            view(3);
            % 如何画出不同方向的DoF还需要再考虑
            %
        end
    end
    methods(Static)
        function obj = AllDoF(point,value)
            arguments
                point (1,1) {mustBeA(point,'Point')}
                value (1,7) {mustBeNumeric} = zeros(1,7)
            end
            DoFs = {'Ux','Uy','Uz','Rotx','Roty','Rotz','Wrap'};
            obj = Constraint(point,DoFs,value);
        end
        function obj = Uxyz(point,value)
            arguments
                point (1,1) {mustBeA(point,'Point')}
                value (1,3) {mustBeNumeric} = zeros(1,3)
            end
            DoFs = {'Ux','Uy','Uz'};
            obj = Constraint(point,DoFs,value);
        end
        function obj = Rxyz(point,value)
            arguments
                point (1,1) {mustBeA(point,'Point')}
                value (1,3) {mustBeNumeric} = zeros(1,3)
            end
            DoFs = {'Rotx','Roty','Rotz'};
            obj = Constraint(point,DoFs,value);
        end


        function collection = Collection()
            persistent Data 
            if isempty(Data)
                Data = ConstraintCollection();
            end
            collection = Data;
        end
        function constrint_list = ConstraintList()
            constrint_list = Constraint.Collection.ObjList;
        end
        function constrint_list = Table()
            constrint_list = Constraint.Collection.Table;
        end
        function constrint_list = getConstraintByNum(Num)
            constrint_list = Constraint.Collection.getObj('Num',Num); % 必须时经过record之后的Point对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                constrint_list = Constraint.ConstraintList;
                if ~isempty(constrint_list)
                    num = [constrint_list.Num];
                else
                    num = [];
                end
            else
                unsorted_num = [obj.Num];
                num = sort(unsorted_num);
            end
            if isempty(num)
                max_num = 0;
            else
                max_num = max(num);
            end
        end
    end
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end
function DoF_list = convertDoF(dof)
    if isa(dof,'cell')
        len = length(dof);
        converted_dof = cell(1,len);
        for i=1:len
            converted_dof{i} = char(dof{i});
        end
    elseif isa(dof,'char')
        converted_dof = {dof};
    elseif isa(dof,'string')
        converted_dof = {char(dof)};
    end
    DoF_list = DoF.empty;
    for i=1:length(converted_dof)
        if strcmp(converted_dof{i},'None')
            DoFObj = DoF.empty;
        elseif ~any(strcmp(converted_dof{i},DoF.All.Name))
            error(['输入的自由度中，第',num2str(i),'个自由度标识： "',converted_dof{i},'" 不在规定输入的自由度标识中。请输入','Ux, Uy, Uz, Rotx, Roty, Rotz','中的一个或多个'])
        else
            DoFObj = DoF.(converted_dof{i});
        end
        DoF_list = [DoF_list,DoFObj];
    end
end