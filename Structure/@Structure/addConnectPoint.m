function addConnectPoint(obj,ConnectPoint,ConnectStructureObj)
    % 输入：
    %   ConnectPoint：在obj.Point中的点，这些点被ConnectStructureObj共用
    %   ConnectStructureObj：与obj共用ConnectPoint的Structure对象
    arguments
        obj
        ConnectPoint {mustBeA(ConnectPoint,["Point","double"])}
        ConnectStructureObj {mustBeA(ConnectStructureObj,'Structure')} = obj
    end
    if ~isempty(ConnectPoint)
        connect_point_table = obj.ConnectPoint_Table;
        sz = size(connect_point_table);
        if isempty(connect_point_table)
            obj.ConnectPoint_Table(end+1,1:2) = {ConnectPoint,ConnectStructureObj};
        else
            structure_list = connect_point_table(:,2);
            index = [];
            for i=1:sz(1)
                if structure_list{i}==ConnectStructureObj
                    index = i;
                end
            end
            if isempty(index) % 如果StructureObj不存在于ConnectPoint_Table中，就在ConnectPoint_Table末尾添加
                obj.ConnectPoint_Table(end+1,1:2) = {ConnectPoint,ConnectStructureObj};% 
            else  % 如果StructureObj已经存在于ConnectPoint_Table中，就把原来的替换掉
                obj.ConnectPoint_Table(i,1:2) = {ConnectPoint,ConnectStructureObj};
            end
        end
    end
end