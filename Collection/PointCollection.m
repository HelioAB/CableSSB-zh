classdef PointCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
        Map
    end
    
    methods
        function PointTable = get.Table(obj)
            ObjList = obj.ObjList;
            len = length(ObjList);
            PointTable = cell(len+1,4);
            PointTable(1,1:4) = {'Point Num','X','Y','Z'};% 表头
            if ~isempty(ObjList)
                Num = [ObjList.Num];
                X = [ObjList.X];
                Y = [ObjList.Y];
                Z = [ObjList.Z];
                [sorted_Num,index] = sort(Num);
                sorted_X = X(index);
                sorted_Y = Y(index);
                sorted_Z = Z(index);
                PointTable(2:end,1:4) = num2cell([sorted_Num',sorted_X',sorted_Y',sorted_Z']);
            end
        end
        function PointMap = get.Map(obj)
            ObjList = obj.ObjList;
            PointMap = containers.Map('KeyType','double','ValueType','any');
            if ~isempty(ObjList)
                for i=1:length(ObjList)
                    PointMap(ObjList(i).Num) = ObjList(i);
                end
            end
        end
        
    end
end
