classdef Group < DataRecord
    properties
        Name
        Point = []
        Line = []
    end    
    
    methods
        function obj = Group(Name,options)
            arguments
                Name (1,:) {mustBeText} = ''
                options.Point {mustBeA(options.Point,"Point")} = Point()
                options.Line {mustBeA(options.Line,"Line")} = Line()
            end
            obj = obj@DataRecord()
            obj.Name = Name;
            if ~isempty([options.Point.Num])
                obj.Point = options.Point;
            end
            if ~isempty([options.Line.Num])
                obj.Line = options.Line;
            end
        end
        function record(obj)
            obj.Num = Group.MaxNum+1;
            record@DataRecord(obj)
        end
        function edit(obj,PropertyName,ChangeTo)
            arguments
                obj
                PropertyName {mustBeMember(PropertyName,{'Name','Point','Line'})}
                ChangeTo
            end
            % Group的三个成员属性都没有编辑前后的size必须相同的要求
            edit@DataRecord(obj,PropertyName,ChangeTo)
        end
        function newobj = clone(obj)
            newobj = Group(obj.Name,'Point',obj.Point,'Line',obj.Line);
        end 
        function [point_handle,line_handle] = plot(obj,options)
            arguments
                obj
                options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
                options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
            end
            figure(options.Figure);
            hold(options.Axis,'on')
            if ~isempty(obj.Point)
                point_handle = obj.Point.plot('Figure',options.Figure,'Axis',options.Axis);
            end
            if ~isempty(obj.Point)
                line_handle = obj.Line.plot('Figure',options.Figure,'Axis',options.Axis);
            end
            hold(options.Axis,'off')
        end
        function tf = isempty(obj)
            tf = isempty@DataRecord(obj);
            if ~isempty([obj.Point]) || ~isempty([obj.Line]) % 只有名字，但Num和Point和Line为空，则视Group为空
                tf = false;
            end
        end
        function Description = getDescription(obj)
            Description.Group = 'Group contains ';
            if ~isempty(obj.Point)
                Description.Group = [Description.Group,num2str(length(obj.Point)),' points'];
            end
            if ~isempty(obj.Line)
                Description.Group = [Description.Group,', ',num2str(length(obj.Line)),' lines'];
            elseif isempty(obj.Point)
                Description.Group = '0 point and 0 line.';
            end
        end
    end
    methods(Static)
        function collection = Collection()
            persistent Data
            if isempty(Data)
                Data = GroupCollection();
            end
            collection = Data;
        end
        function group_list = GroupList()
            group_list = Group.Collection.ObjList;
        end
        function group_map = Map()
            group_map = Group.Collection.Map;
        end
        function group_table = Table()
            group_table = Group.Collection.Table;
        end
        function update(PropertyName,ChangeTo)
            Group.Collection.updateObjList(PropertyName,ChangeTo)
        end
        function Obj = getGroupByName(Name)
            arguments
                Name (1,:) {mustBeText}
            end
            Obj = Group.Collection.getObj('Name',Name);
        end
        function max_num = MaxNum(obj)
            if nargin==0
                group_list = Group.GroupList;
                if ~isempty(group_list)
                    num = [group_list.Num];
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