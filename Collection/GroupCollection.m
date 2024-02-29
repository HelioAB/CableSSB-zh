classdef GroupCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
        Map
    end
    
    methods
        function GroupTable = get.Table(obj)
            ObjList = obj.ObjList;
            len = length(ObjList);
            GroupTable = cell(len+1,4);
            GroupTable(1,1:4) = {'Group Num','Group Name','Point Num','Line Num'};
            if ~isempty(ObjList)
                for i=1:len
                    if ~isempty(ObjList(i).Num)
                        Num = ObjList(i).Num;
                    else
                        Num = [];
                    end
                    if ~isempty(ObjList(i).Name)
                        Name = ObjList(i).Name;
                    else
                        Name = '';
                    end
                    if ~isempty(ObjList(i).Point)
                        Point_num = [ObjList(i).Point.Num];
                    else
                        Point_num = [];
                    end
                    if ~isempty(ObjList(i).Line)
                        Line_num = [ObjList(i).Line.Num];
                    else
                        Line_num = [];
                    end

                    [sorted_Num,index] = sort(Num);
                    sorted_Name = Name(index);
                    sorted_PointNum = Point_num(index);
                    sorted_LineNum = Line_num(index);

                    GroupTable(i+1,1:4) = {sorted_Num',sorted_Name',sorted_PointNum',sorted_LineNum'};
                end
            end
        end
        function GroupMap = get.Map(obj)
            ObjList = obj.ObjList;
            GroupMap = containers.Map('KeyType','char','ValueType','any');
            if ~isempty(ObjList)
                for i=1:length(ObjList)
                    Coord = struct;
                    Coord.Point = ObjList(i).Point;
                    Coord.Line = ObjList(i).Line;
                    GroupMap(ObjList(i).Name) = Coord;
                end
            end
        end
%         function [rep_name,rep_obj,rep_index,uni_name,uni_obj,uni_index] = findRepName(obj)
%             ObjList = obj.ObjList;
%             rep_name = {}; % {name_1,name_2}
%             rep_obj = {}; % {[obj_1,obj_4],[obj_3,obj_5]}
%             rep_index = {}; % {[index_1,index_4],[index_3,index_5]}
%             uni_name = {}; % {name_3,name_4,name_5} 
%             uni_obj = []; % [obj_3,obj_4,obj_5]
%             uni_index = [];% [index_3,index_4,index_5]
%             if ~isempty(ObjList)
%                 Name = {ObjList.Name};
%                 for i=1:length(Name)
%                     index = strcmp(Name,Name{i});
%                     if i>=2
%                         index(1,1:i-1) = false;
%                     end
%                     if sum(index) >= 2
%                         rep_name = {rep_name,Name{i}};
%                         rep_obj{end+1} = ObjList(index);
%                         rep_index{end+1} = index;
%                     end
%                 end
%                 [uni_name,uni_index] = unique({ObjList.Name});
%                 uni_obj = ObjList(uni_index);
%             end
%             
%             if ~isempty(rep_name)
%                 assignin("base","RepNum",rep_name)
%                 assignin("base","RepIndex",rep_index)
%                 assignin("base","RepObj",rep_obj)
%             end
%         end
    end
end
