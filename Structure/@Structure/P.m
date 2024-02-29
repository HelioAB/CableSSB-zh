function [P_x,P_y,P_z] = P(obj,Num_ForcePoint,P_force_x,P_force_y,P_force_z)
    % 输入P_force_x的向量长度应与Num_ForcePoint相同，均为方便输入
    % 输出P_x,P_y,P_z用于整体分析
    arguments
        obj
        Num_ForcePoint % 非零荷载作用点编号
        P_force_x {mustBeNumeric} = [] % 锚固点处外力的x方向分量
        P_force_y {mustBeNumeric} = []
        P_force_z {mustBeNumeric} = []
    end
    
    num_force = obj.PointNum2Num(Num_ForcePoint); % 将不同输入形式的Force转变成需要的格式，只需要在不同子类中重载convert2Num方法
    
    % 输入参数验证
    mustBeNumeric(num_force)
    % setForcePoint设置了ForcePoint属性
    obj.setForcePoint(num_force);
    if isempty(P_force_x)
        P_force_x = zeros(size(num_force));
    end
    if isempty(P_force_y)
        P_force_y = zeros(size(num_force));
    end
    if isempty(P_force_z)
        P_force_z = zeros(size(num_force));
    end
    mustBeEqualSize(num_force,P_force_x)
    mustBeEqualSize(num_force,P_force_y)
    mustBeEqualSize(num_force,P_force_z)
    
    % 计算P_x,P_y,P_z
    n_point = length(obj.Point);
    P_x = zeros(1,n_point);
    P_y = zeros(1,n_point);
    P_z = zeros(1,n_point);
    index_force = obj.Index_Force;
    i_force = 1;
    if ~isempty(P_force_z)
        for i=1:n_point
            if index_force(i)
                P_x(i) = P_force_x(i_force);
                P_y(i) = P_force_y(i_force);
                P_z(i) = P_force_z(i_force);
                i_force = i_force + 1;
            end
        end
    end
    % 记录
    obj.Params.P_x = P_x;
    obj.Params.P_y = P_y;
    obj.Params.P_z = P_z;
    obj.Params.P_force_x = P_force_x;
    obj.Params.P_force_y = P_force_y;
    obj.Params.P_force_z = P_force_z;
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end