classdef LoadCollection < CellCollection
    properties(SetAccess=protected,Dependent)
        Table
    end
    methods
        function LoadTable = get.Table(obj)
            objList = obj.ObjList;
            len = length(objList);
            LoadTable = cell(len+1,7);
            LoadTable(1,:) = {'Load Num','Load Type','Apply Location','Direction','Value','Load Name','Load'};
            if len
                for i=1:len
                    if ~isempty([objList{i}.Num])
                        Num = [objList{i}.Num];
                    else
                        Num = [];
                    end
                    load_type = objList{i}.LoadType;
                    application = [objList{i}.Application];
                    direction = objList{i}.Direction;
                    value = objList{i}.Value;
                    if ~isempty(objList{i}.Name)
                        Name = objList{i}.Name;
                    else
                        Name = '';
                    end
                    load = objList{i};
                    LoadTable(i+1,1:7) = {Num,load_type,application,direction,value,Name,load};
                end
            end
% 
%             if ~isempty(objList)
%                 obj_num = [objList.Num];
%                 for i=1:len
%                     Num = obj_num(i);
%                     load_type = objList(i).LoadType;
%                     if isa(objList(i).Application,'Point')
%                         point_num = objList(i).Application.Num;
%                         line_num = [];
%                     elseif isa(objList(i).Application,'Line')
%                         point_num = [];
%                         line_num = objList(i).Application.Num;
%                     end
%                     direction = objList(i).Direction;
%                     value = objList(i).Value;
%                     LoadTable(i+1,1:6) = {Num,load_type,point_num,line_num,direction,value};
%                 end
%                 [~,index] = sort(obj_num);
%                 LoadTable(2:end,:) = LoadTable(1+index',:);
%             end
        end
        
    end
end