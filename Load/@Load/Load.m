classdef Load < DataRecord
    properties
        Name
        LoadType
        AppliedPosition
        Direction
        Value
    end
    
    methods
        function obj = Load(applied_position,direction,value,loadtype)
            arguments
                applied_position = []
                direction {mustBeMember(direction,{'X','Y','Z','None'})} = 'None'
                value {mustBeA(value,'cell'),mustBeEqualSize(applied_position,value)} = {}% 输入的value的length应该为size == (1,length(aplliedposition))的cell类型
                loadtype {mustBeText} = ''
            end
            obj = obj@DataRecord();
            % 参数验证
            mustBeA(applied_position,{'Point','Line'})
            obj.Name = '';
            obj.LoadType = loadtype;
            obj.AppliedPosition = applied_position;
            obj.Direction = char(direction);
            obj.Value = value;
        end
        record(obj)
    end

    methods(Static)
        function value_added = ValueAddition(Value1,Value2)
            value_added = {Value1{:}+Value2{:}};
        end
        function value_summed = ValueSum(ValueCell)% 不同数据结构的荷载值的相加方式, ValueCell = {value1,value2,value3},其中value1 = {[1,3;4,3]}其他valuei与value1的size相同
            value_summed = {zeros(size(ValueCell{1}))};
            for i=1:length(ValueCell)
                Value_i = ValueCell(i);
                value = value_summed{:} + Value_i{:};
                value_summed = {value};
            end
        end
        function Map_ClassifiedLoad = classifyLoad(LoadList,class_names)
            % 输入：
            %   LoadList: 装Load对象的cell，例如: 1*2 cell数组 {1*1 UniformLoad} {1*2 ConcentratedForce}
            %   class_name：例如: {'UniformLoad','ConcentratedForce'}
            % 输出：
            %   Map_ClassifiedLoad：以class_name为key，Load对象数组为value的映射，使用方式例如：Map_ClassifiedLoad('UniformLoad') == [1*10 UniformLoad]
            arguments
                LoadList {mustBeA(LoadList,'cell')}
                class_names {mustBeText,mustBeA(class_names,'cell')}
            end
            len_name = length(class_names);
            len_load = length(LoadList);
            Map_ClassifiedLoad = containers.Map('KeyType','char','ValueType','any');
            for i=1:len_load
                for j=1:len_name
                    if isa(LoadList{i},class_names{j})
                        key_map = keys(Map_ClassifiedLoad);
                        if any(strcmp(key_map,class_names{j})) % 如果Map中存在这个class_name
                            load_cell = Map_ClassifiedLoad(class_names{j});
                            load_cell(end+1) = LoadList{i};
                            Map_ClassifiedLoad(class_names{j}) = load_cell;
                        else
                            Map_ClassifiedLoad(class_names{j}) = LoadList{i}; % 分类后的类以对象数组的形式存在
                        end
                    end
                end
            end
        end
        function MergedLoadList = mergeLoadByApplicationPosition(LoadList)
            % 输入：
            %   LoadList: Load对象数组，不是cell，例如: [1*12 UniformLoad]
            % 输出：
            %   MergedLoadList：在相同作用位置、相同Direction的Load对象，其Value相加，形成的Load对象数组
            Name_list = {LoadList.Name};
            LoadType_list = {LoadList.LoadType};
            AppliedPosition_list = {LoadList.AppliedPosition};
            Direction_list = {LoadList.Direction};
            Value_list = {LoadList.Value};
        end
        function arrow = getArrow(apply_point,delta_X,delta_Y,delta_Z,color,fig,ax)
            % 使用Matlab内置quiver3函数
            % delta_Coord的列数必须和apply_point相同
            arguments
                apply_point
                delta_X {mustBeEqualSize(apply_point,delta_X)}
                delta_Y {mustBeEqualSize(apply_point,delta_Y)}
                delta_Z {mustBeEqualSize(apply_point,delta_Z)}
                color = 'm'
                fig {mustBeA(fig,'matlab.ui.Figure')} = figure
                ax {mustBeA(ax,'matlab.graphics.axis.Axes')} = axes
            end
            % 箭头指向处坐标
            end_X = [apply_point.X];
            end_Y = [apply_point.Y];
            end_Z = [apply_point.Z];
            % 箭尾处坐标
            start_X = end_X-delta_X;
            start_Y = end_Y-delta_Y;
            start_Z = end_Z-delta_Z;
            
            figure(fig)
            arrow = quiver3(ax,start_X,start_Y,start_Z,delta_X,delta_Y,delta_Z,'off');
            arrow.Color = color;
            arrow.MaxHeadSize  = 0.1;
        end
        function collection = Collection()
            persistent Data 
            if isempty(Data)
                Data = LoadCollection();
            end
            collection = Data;
        end
        function load_list = LoadList()
            load_list = Load.Collection.ObjList;
        end
        function load_list = Table()
            load_list = Load.Collection.Table;
        end
        function load = getLoadByNum(Num)
            load = Load.Collection.getObj('Num',Num); % 必须时经过record之后的Point对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                num = Load.Collection.Num;
            else
                num = [obj.Num];
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
    if isempty(a) && isempty(b)
    elseif ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end