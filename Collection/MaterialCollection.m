classdef MaterialCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
    end
    
    methods
        function MaterialTable = get.Table(obj)
            objList = obj.ObjList;
            len = length(objList);
            MaterialTable = cell(len+1,3);
            MaterialTable(1,1:4) = {'Num','Name','MaterialData','Material'};
            if len
                for i=1:len
                    if ~isempty(objList(i).Num)
                        Num = objList(i).Num;
                    else
                        Num = [];
                    end
                    if ~isempty(objList(i).Name)
                        Name = objList(i).Name;
                    else
                        Name = '';
                    end
                    if ~isempty(objList(i).MaterialData)
                        MaterialData = objList(i).MaterialData;
                    else
                        MaterialData = [];
                    end
                    MaterialTable(i+1,1:4) = {Num,Name,MaterialData,objList(i)};
                end
            end
        end
       
    end
end
