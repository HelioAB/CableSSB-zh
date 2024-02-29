classdef ElementType < DataRecord
    properties
        Name
    end
    methods
        function record(obj)
            if ~obj.flag_recorded
                max_num = ElementType.MaxNum;
                obj.Num = max_num+1;
                obj.Collection.addObj(obj);
                obj.flag_recorded = true;
            end
        end
        function tf = isempty(obj)
            if length(obj)==0
                tf = true; 
            else
                tf = false;
            end
        end
    end
    methods(Abstract)
        Matrix = StiffnessMatrix(obj) % 待实现
    end

    methods(Static)
        function collection = Collection() 
            % 方法伪装成属性，完全等价于Static变量，且Collection可重载
            persistent Data
            if isempty(Data)
                Data = ElementTypeCollection();
            end
            collection = Data;
        end
        function ElementType_list = ElementTypeList()
            ElementType_list = ElementType.Collection.ObjList;
        end
        function ElementType_table = Table()
            ElementType_table = ElementType.Collection.Table;
        end
        function Obj = getElementTypeByNum(Num)
            arguments
                Num (1,1) {mustBeInteger}
            end
            Obj = ElementType.Collection.getObj('Num',Num);
        end
        function Obj = getElementTypeByName(Name)
            arguments
                Name (1,:) {mustBeText}
            end
            Obj = ElementType.Collection.getObj('Name',Name);
        end
        function max_num = MaxNum(obj)
            if nargin==0
                num = [ElementType.Table{2:end,1}];
            else
                unsorted_num = [obj.Num];
                num = sort(unsorted_num);
            end
            if isempty(num)
                max_num = 0;
            else
                max_num = num(end);
            end
        end
        function [sorted_objlist,Index] = sortByNum()
            [sorted_objlist,Index] = ElementType.Collection.sortObjList('Num');
        end
    end
end