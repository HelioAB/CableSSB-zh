function setForcePoint(obj,Num)
    % 如果可以通过Index设置ForcePoint，可以直接令obj.ForcePoint = obj.Point(Index)
    % 如果只能通过点号设置ForcePoint,就需要使用本方法
    arguments
        obj
        Num {mustBeInteger}
    end
    uni_num = unique(Num);
    if length(uni_num) ~= length(Num)
        error('输入的受力点的编号Num不应有重复编号')
    end
    num_point = [obj.Point.Num];
    num_force = [];
    for i=1:length(Num)
        if any(Num(i)==num_point) % 如果输入的Num，存在于obj.NewPoint中
            num_force(1,end+1) = Num(i);
        else
            warning(['输入编号',num2str(Num(i)),'不在Point中'])
        end
    end
    obj.ForcePoint = obj.Point.findObjByNum(num_force);
end