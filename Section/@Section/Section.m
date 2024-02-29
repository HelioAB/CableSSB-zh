classdef Section < DataRecord
    % 该类仅作为Section数据与外部交互的adapter
    properties
        Name
        SectionData
    end
    methods
        function obj = Section(Name,SectionData)
            if nargin == 1
                obj.Name = Name;
            elseif nargin == 0
                obj.Name = '';
            elseif nargin==2
                obj.Name = Name;
                obj.SectionData = SectionData;
            end
        end
        record(obj)
        [uni_obj,index_input2uni,index_uni2input] = unique(obj)
        A = Area(obj)
        edit(obj,PropertyName,ChangeTo)
        newobj = clone(obj)
        tf = isempty(obj)
    end
    methods(Static)
        function collection = Collection() 
            % 方法伪装成属性，完全等价于Static变量，且Collection可重载
            persistent Data
            if isempty(Data)
                Data = SectionCollection();
            end
            collection = Data;
        end
        function section_list = SectionList()
            section_list = Section.Collection.ObjList;
        end
        function section_table = Table()
            section_table = Section.Collection.Table;
        end
        function Obj = getSectionByNum(Num)
            arguments
                Num (1,1) {mustBeInteger}
            end
            Obj = Section.Collection.getObj('Num',Num);
        end
        function Obj = getSectionByName(Name)
            arguments
                Name (1,:) {mustBeText}
            end
            Obj = Section.Collection.getObj('Name',Name);
        end
        function max_num = MaxNum(obj)
            if nargin==0
                num = [Section.Table{2:end,1}];
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
            [sorted_objlist,Index] = Section.Collection.sortObjList('Num');
        end
    end
end