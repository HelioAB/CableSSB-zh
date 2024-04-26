classdef Coupling < DataRecord
    properties
        Name
        MasterPoint
        SlavePoint
        DoFs
    end
    methods
        function obj = Coupling(MasterPoint,SlavePoint,dof)
            arguments
                MasterPoint (1,1) {mustBeA(MasterPoint,'Point')} = Point()
                SlavePoint (1,:) {mustBeA(SlavePoint,'Point')} = Point()
                dof {mustBeText} = 'None'
            end
            
            obj = obj@DataRecord();
            if nargin
                if isempty(SlavePoint)
                    error('Coupling的SlavePoint为空，请检查')
                end
                for i=1:length(SlavePoint)
                % 判断是否有主节点和从节点相同
                    if any(SlavePoint(i)==MasterPoint)
                        error(['输入的从节点列表中，第',num2str(i),'个从节点与主节点相同，请修改'])
                    end
                    % 判断是否有不同从节点相同
                    if sum(SlavePoint(i)==SlavePoint)>1
                        error(['输入的从节点列表中，第',num2str(i),'个从节点和其他从节点相同，请修改'])
                    end
                end
                obj.Num = Coupling.MaxNum+1;
                obj.Name = '';
                obj.MasterPoint = MasterPoint;
                obj.SlavePoint = SlavePoint;
                obj.DoFs = convertDoF(dof);
            end
        end
        function [point_hande,line_handle] = plot(obj,S,C,options)
            arguments
                % 均为MATLAB中默认的参数值
                obj (1,1)
                S = 12
                C = [0,149,182]/255
                options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
                options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
            end
            % 其他参数通过访问对象point_handle的属性值修改
            
            hold(options.Axis,'on')
            slave_point = obj.SlavePoint;
            master_point = obj.MasterPoint;
            len_slave = length(slave_point);
            master_point_list(1,len_slave) = master_point;
            point = [master_point,slave_point];
            for j=1:len_slave
                master_point_list(1,j) = master_point;
            end
            line = Line([],master_point_list,slave_point);
            line_handle = line.plot("Color",C,"Figure",options.Figure,"Axis",options.Axis);
            point_hande = point.plot(S,C,'Filled',true,"Figure",options.Figure,"Axis",options.Axis);
            view(3);
        end
    end
    methods(Static)
        function obj = AllDoF(MasterPoint,SlavePoint)
            DoFs = {'Ux','Uy','Uz','Rotx','Roty','Rotz'};
            obj = Coupling(MasterPoint,SlavePoint,DoFs);
        end
        function obj = Uxyz(MasterPoint,SlavePoint)
            DoFs = {'Ux','Uy','Uz'};
            obj = Coupling(MasterPoint,SlavePoint,DoFs);
        end
        function obj = Rxyz(MasterPoint,SlavePoint)
            DoFs = {'Rotx','Roty','Rotz'};
            obj = Coupling(MasterPoint,SlavePoint,DoFs);
        end


        function collection = Collection()
            persistent Data 
            if isempty(Data)
                Data = CouplingCollection();
            end
            collection = Data;
        end
        function coupling_list = CouplingList()
            coupling_list = Coupling.Collection.ObjList;
        end
        function coupling_list = Table()
            coupling_list = Coupling.Collection.Table;
        end
        function coupling_list = getCouplingByNum(Num)
            coupling_list = Coupling.Collection.getObj('Num',Num); % 必须时经过record之后的Point对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                coupling_list = Coupling.CouplingList;
                if ~isempty(coupling_list)
                    num = [coupling_list.Num];
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