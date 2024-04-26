classdef Point < DataRecord
    properties
        % Point对象的Num,X,Y,Z属性均不能为空
        X
        Y
        Z
    end
    methods
        function obj = Point(Num,X,Y,Z)
            arguments
                Num = []
                X = []
                Y = []
                Z = []
            end
            obj = obj@DataRecord();
            if nargin ~= 0
                % 参数验证
                % 因为Matlab中的argument是先验证参数，再赋予变量默认值。所以不输入参数时，不能进行参数验证
                mustBeInteger(Num);
                mustBePositive(Num);
                mustBeNumeric(X);
                mustBeNumeric(Y);
                mustBeNumeric(Z);
                mustBeEqualSize(X,Y)
                mustBeEqualSize(X,Z)
                len = length(X);
                if ~isempty(Num) % 如果手动输入Num的值，就一定要与XYZ有相同的size
                    mustBeEqualSize(X,Num)
                else % 否则就输入[]就行
                    Num = Point.MaxNum()+[1:len];
                end
                % 创建对象数组
                obj(1,len) = Point(); % 这里会有类似递归的操作，因此终止条件很重要
                for i = 1:len
                    obj(1,i).Num = Num(1,i);
                    obj(1,i).X = X(1,i);
                    obj(1,i).Y = Y(1,i);
                    obj(1,i).Z = Z(1,i);
                end
            else
                obj.Num = [];
                obj.X = [];
                obj.Y = [];
                obj.Z = [];
            end
        end
        edit(obj,PropertyName,ChangeTo)
        newobj = clone(obj) % 需要重载
        [fig,ax] = plot(obj,S,C,options)
        moveTo(obj,coord)
        translate(obj,difference)
        symmetrize(obj,symmetric_point,normal_vector_direction)
        [merged_point,merged_index,used_point,discarded_point] = merge(obj,tolerance)
        obj = reverse(obj)
        coord = Coord(obj)
        point_table = Info(obj)
        [point_list,index_list] = findPointByCoord(obj,X,Y,Z,tolerance)
        [point,index] = findPointByRange(obj,XRange,YRange,ZRange,tolerance)
        InterpolatedPoints = interpolatePoints(obj,options)
        sortedPoints = sortByDistance(obj,reference)
    end
    methods(Static)
        function collection = Collection()
            persistent Data
            if isempty(Data)
                Data = PointCollection();
            end
            collection = Data;
        end
        function point_list = PointList()
            point_list = Point.Collection.ObjList;
        end
        function point_map = Map()
            point_map = Point.Collection.Map;
        end
        function point_table = Table()
            point_table = Point.Collection.Table;
        end
        function update(PropertyName,ChangeTo)
            Point.Collection.updateObjList(PropertyName,ChangeTo)
        end
        function point = getPointByNum(Num)
            point = Point.Collection.getObj('Num',Num); % 必须时经过record之后的Point对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                point_list = Point.PointList;
                if ~isempty(point_list)
                    num = [point_list.Num];
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