classdef Material < DataRecord
    properties
        Name
        MaterialData
    end
    methods
        function obj = Material(Name,MaterialData)
            if nargin == 1
                obj.Name = Name;
            elseif nargin == 0
                obj.Name = '';
            elseif nargin==2
                obj.Name = Name;
                obj.MaterialData = MaterialData;
            end
        end
        record(obj)
        edit(obj,PropertyName,ChangeTo)
        newobj = clone(obj)
        tf = isempty(obj)
        [material_data_struct,name,value] = getAllMaterialData(obj)
    end
    methods(Static)
        function collection = Collection() 
            % 方法伪装成属性，完全等价于Static变量，且Collection可重载
            persistent Data
            if isempty(Data)
                Data = MaterialCollection();
            end
            collection = Data;
        end
        function Material_list = MaterialList()
            Material_list = Material.Collection.ObjList;
        end
        function Material_table = Table()
            Material_table = Material.Collection.Table;
        end
        function Obj = getMaterialByNum(Num)
            arguments
                Num (1,1) {mustBeInteger}
            end
            Obj = Material.Collection.getObj('Num',Num);
        end
        function Obj = getMaterialByName(Name)
            arguments
                Name (1,:) {mustBeText}
            end
            Obj = Material.Collection.getObj('Name',Name);
        end
        function max_num = MaxNum(obj)
            if nargin==0
                num = [Material.Table{2:end,1}];
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
            [sorted_objlist,Index] = Material.Collection.sortObjList('Num');
        end
    end
end