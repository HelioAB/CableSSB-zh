classdef Line < DataRecord
    properties
        IPoint
        JPoint
        KPoint
    end
    methods
        function obj = Line(Num,IPoint,JPoint)
            arguments
                Num = []
                IPoint = []
                JPoint = []
            end
            obj = obj@DataRecord()
            if nargin ~= 0
                % 参数验证
                mustBeInteger(Num);
                mustBePositive(Num);
                mustBeA(IPoint,["Point","double"])
                mustBeA(JPoint,["Point","double"])
                mustBeEqualSize(IPoint,JPoint)
                len = length(IPoint);
                if ~isempty(Num)
                    mustBeEqualSize(IPoint,Num)
                else
                    Num = Line.MaxNum()+[1:len];
                end
                % 创建对象数组
                obj(1,len) = Line();
                for i = 1:len
                    obj(1,i).Num = Num(1,i);
                    obj(1,i).IPoint = IPoint(1,i);
                    obj(1,i).JPoint = JPoint(1,i);
                end
            else
                obj.Num = [];
                obj.IPoint = [];
                obj.JPoint = [];
            end
        end
        function setKPoint(obj,KPoint)
            len = length(obj);
            if length(KPoint)==0
                for i=1:len
                    obj(i).KPoint = [];
                end
            else
                mustBeA(KPoint,'Point')
            end
            
            if length(KPoint)==len
                for i=1:len
                    obj(i).KPoint = KPoint(i);
                end
            elseif length(KPoint)==1
                for i=1:len
                    obj(i).KPoint = KPoint;
                end
            
            end
        end
        
        edit(obj,PropertyName,ChangeTo)
        newobj = clone(obj)
        [unipoint,index_IPoint,index_JPoint] = uniPoint(obj)
        line_handle = plot(obj,options)
        line_table = Info(obj)
        len = LineLength(obj)
        [delta_x,delta_y,delta_z] = DeltaLength(obj)
        merge(obj,tolerance)
        disconnected_point = disconnect(obj,connect_point)
        [I_flag,J_flag] = locatePoint(obj,point)
        coord_centerpoint = getCenterPointCoord(obj)
        [Norm_x,Norm_y,Norm_z] = getLocalCoordSystem(obj,tol)
        [Comp_x,Comp_y,Comp_z] = getLocalCoordSystemComponent(obj,GlobalDirection,tol) % 给定一个大小和方向direction（1*3数值向量），获得在局部坐标系的各个分量
        plotLocalCoordSystem(obj,OriginCoord,options)
        
    end


    methods(Static)
        function collection = Collection()
            persistent Data
            if isempty(Data)
                Data = LineCollection();
            end
            collection = Data;
        end
        function line_list = LineList()
            line_list = Line.Collection.ObjList;
        end
        function line_map = Map()
            line_map = Line.Collection.Map;
        end
        function line_table = Table()
            line_table = Line.Collection.Table;
        end
        function update(PropertyName,ChangeTo)
            Line.Collection.updateObjList(PropertyName,ChangeTo)
        end
        function Obj = getLineByNum(Num)
            arguments
                Num (1,1) {mustBeInteger}
            end
            Obj = Line.Collection.getObj('Num',Num); % 必须时经过record之后的Line对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                line_list = Line.LineList;
                if ~isempty(line_list)
                    num = [line_list.Num];
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