classdef SectionCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
    end
    
    methods
        function SectionTable = get.Table(obj)
            objList = obj.ObjList;
            len = length(objList);
            SectionTable = cell(len+1,3);
            SectionTable(1,1:4) = {'Num','Name','SectionData','Section'};
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
                    if ~isempty(objList(i).SectionData)
                        SectionData = objList(i).SectionData;
                    else
                        SectionData = [];
                    end
                    SectionTable(i+1,1:4) = {Num,Name,SectionData,objList(i)};
                end
            end
        end
       
    end
end
