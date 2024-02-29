classdef ConstraintCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
    end
    
    methods
        function ConstraintTable = get.Table(obj)
            ObjList = obj.ObjList;
            len = length(ObjList);
            ConstraintTable = cell(len+1,5);
            ConstraintTable(1,:) = {'Constraint Num','Point Num','DoF','Value','Constraint'};

            if ~isempty(ObjList)
                obj_num = [ObjList.Num];
                for i=1:len
                    Num = obj_num(i);
                    PointNum = ObjList(i).Point.Num;
                    DoF = ObjList(i).DoF;
                    Value = ObjList(i).Value;
                    ConstraintTable(i+1,1:5) = {Num,PointNum,DoF,Value,ObjList(i)};
                end
                [~,index] = sort(obj_num);
                ConstraintTable(2:end,:) = ConstraintTable(1+index',:);
            end
        end
        
    end
end
