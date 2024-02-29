classdef CouplingCollection < ArrayCollection
    properties(SetAccess=protected,Dependent)
        Table
    end
    
    methods
        function CouplingTable = get.Table(obj)
            ObjList = obj.ObjList;
            len = length(ObjList);
            CouplingTable = cell(len+1,5);
            CouplingTable(1,:) = {'Coupling Num','DoF','Master Point Num','Slave Point Num','Coupling'};
            if ~isempty(ObjList)
                obj_num = [ObjList.Num];
                for i=1:len
                    Num = obj_num(i);
                    DoF = ObjList(i).DoF;
                    MasterPoint_Num = ObjList(i).MasterPoint.Num;
                    SlavePoint_Num = [ObjList(i).SlavePoint.Num];
                    CouplingTable(i+1,1:5) = {Num,DoF,MasterPoint_Num,SlavePoint_Num,ObjList(i)};
                end
                [~,index] = sort(obj_num);
                CouplingTable(2:end,:) = CouplingTable(1+index',:);
            end
        end
        
    end
end
