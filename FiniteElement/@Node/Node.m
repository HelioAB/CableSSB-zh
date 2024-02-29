classdef Node < DataRecord
    properties
        X
        Y
        Z
        Displacement_GlobalCoord = nan(6,1) % 存储节点位移结果（u, v, w, theta_x, theta_y, theta_z），整体坐标系下。注意初始状态应该不能是0，这里使用NaN表示节点位移未定
    end

    methods
        function obj = Node(Num,X,Y,Z)
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
                obj(1,len) = Node(); % 这里会有类似递归的操作，因此终止条件很重要
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
        coord = Coord(obj)
        point_handle = plot(obj,S,C,options)
    end
    methods(Static)
        function collection = Collection()
            persistent Data
            if isempty(Data)
                Data = NodeCollection();
            end
            collection = Data;
        end
        function node_list = NodeList()
            node_list = Node.Collection.ObjList;
        end
        function node_map = Map()
            node_map = Node.Collection.Map;
        end
        function node_table = Table()
            node_table = Node.Collection.Table;
        end
        function update(PropertyName,ChangeTo)
            Node.Collection.updateObjList(PropertyName,ChangeTo)
        end
        function node = getNodeByNum(Num)
            node = Node.Collection.getObj('Num',Num); % 必须时经过record之后的Point对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                node_list = Node.NodeList;
                if ~isempty(node_list)
                    num = [node_list.Num];
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