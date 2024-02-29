 function disconnected_point = disconnect(obj,connect_point)
    % 输入
    arguments
        obj
        connect_point (1,:) {mustBeA(connect_point,{'double','Point'})}
    end
        % 假设obj = [lien1,line2,line3];
    % disconnect_point_num可以为数值向量
        ipoint = [obj.IPoint];
        jpoint = [obj.JPoint];
    ijpoint = [ipoint,jpoint];
    uni_point = unique(ijpoint);
    if isa(connect_point,'double')
        connect_point_num = connect_point;
        connect_point = uni_point.findObjByNum(connect_point_num);
    end
    if isa(connect_point,'Point')
        connect_point_num = [connect_point.Num];
    end
    disconnected_point = cell(1,length(connect_point_num));
        for i=1:length(connect_point_num)
        index_ipoint = connect_point(i) == ipoint;
        index_jpoint = connect_point(i) == jpoint;
        count_connectline = sum(index_ipoint)+sum(index_jpoint);
        disconnect_line = obj(index_ipoint|index_jpoint);
        clone_point_list = Point().empty;
        for j=1:count_connectline-1
            clone_point = connect_point(i).clone;
            clone_point.Num = Point.MaxNum+j;
            clone_point.record;
            clone_point_list(1,j) = clone_point;
        end
        reconnect_point = [connect_point(i),clone_point_list];
        count = 1;
        for j=1:length(obj)
            if index_ipoint(j)
                disconnect_line(count).IPoint = reconnect_point(count);
                count = count+1;
            end
            if index_jpoint(j)
                disconnect_line(count).JPoint = reconnect_point(count);
                count = count+1;
            end
        end
        disconnected_point{1,i} = reconnect_point;
    end
end