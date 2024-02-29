classdef ElementCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
        Map
    end
    
    methods
        function ElementTable = get.Table(obj)
            ObjList = obj.ObjList;
            len = length(ObjList);
            ElementTable = cell(len+1,3);
            ElementTable(1,1:3) = {'Element Num','INode Num','JNode Num'};% 表头
            if ~isempty(ObjList)
                Num = [ObjList.Num];
                INode = [ObjList.INode];
                JNode = [ObjList.JNode];
                [sorted_Num,index] = sort(Num);
                sorted_INode = INode(index);
                sorted_JNode = JNode(index);
                ElementTable(2:end,1:3) = num2cell([sorted_Num',[sorted_INode.Num]',[sorted_JNode.Num]']);
            end
        end
        function ElementMap = get.Map(obj)
            ObjList = obj.ObjList;
            ElementMap = containers.Map('KeyType','double','ValueType','any');
            if ~isempty(ObjList)
                for i=1:length(ObjList)
                    ElementMap(ObjList(i).Num) = ObjList(i);
                end
            end
        end
    end
end
