classdef ElementTypeCollection < CellCollection
    properties(SetAccess=protected,Dependent)
        Table
    end
    
    methods
        function ElementTypeTable = get.Table(obj)
            objList = obj.ObjList;
            len = length(objList);
            ElementTypeTable = cell(len+1,3);
            ElementTypeTable(1,1:3) = {'Num','Name','ElementType'};
            if len
                for i=1:len
                    if ~isempty(objList{i}.Num)
                        Num = objList{i}.Num;
                    else
                        Num = [];
                    end
                    if ~isempty(objList{i}.Name)
                        Name = objList{i}.Name;
                    else
                        Name = '';
                    end
                    element_type = objList{i};
                    ElementTypeTable(i+1,1:3) = {Num,Name,element_type};
                end
            end
        end
       
    end
end
