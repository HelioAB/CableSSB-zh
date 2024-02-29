classdef LineCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
        Map
    end
    
    methods
        function LineTable = get.Table(obj)
            ObjList = obj.ObjList;
            len = length(ObjList);
            LineTable = cell(len+1,3);
            LineTable(1,1:3) = {'Line Num','IPoint Num','JPoint Num'};% 表头
            if ~isempty(ObjList)
                Num = [ObjList.Num];
                IPoint = [ObjList.IPoint];
                JPoint = [ObjList.JPoint];
                [sorted_Num,index] = sort(Num);
                sorted_IPoint = IPoint(index);
                sorted_JPoint = JPoint(index);
                LineTable(2:end,1:3) = num2cell([sorted_Num',[sorted_IPoint.Num]',[sorted_JPoint.Num]']);
            end
        end
        function LineMap = get.Map(obj)
            ObjList = obj.ObjList;
            LineMap = containers.Map('KeyType','double','ValueType','any');
            if ~isempty(ObjList)
                for i=1:length(ObjList)
                    LineMap(ObjList(i).Num) = ObjList(i);
                end
            end
        end
    end
end
