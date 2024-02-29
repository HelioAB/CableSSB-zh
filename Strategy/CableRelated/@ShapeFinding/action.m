function Output = action(obj,Params,P_x,P_y,P_z)
    % 本方法只负责计算出各种参数，并放在Output中
    [Params,P_x,P_y,P_z] = obj.ParamsAdaptor(Params,P_x,P_y,P_z);
    Output = obj.AlgoHandle(Params,P_x,P_y,P_z); % 修改输出参数
    X = Output.X;
    Y = Output.Y;
    Z = Output.Z;
    [X,Y,Z] = obj.moveToPosition(Params,X,Y,Z);

    % 需要把所有Algo输出的东西全部放在Output这个struct里面，因为不同的Algo可能输出不同的东西
    Output.X = X;
    Output.Y = Y;
    Output.Z = Z;
end