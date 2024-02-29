function [Params_converted,P_x_converted,P_y_converted,P_z_converted] = ParamsAdaptor(obj,Params,P_x,P_y,P_z)
    Input_Params_Description = {'Params上的参数名','该参数名的解释';};
    try
        % 参数转换： Params中存储的各种参数转换到Params_converted中
        % Params是主程序中存储起来的，其参数名及其解释在变量InputParamsDescription中
        % Params_converted是obj.AlgoHandle需要输入的参数名
        Params_converted = Params;
        P_x_converted = P_x;
        P_y_converted = P_y;
        P_z_converted = P_z;
    catch ME
        if strcmp(ME.identifier,'MATLAB:nonExistentField')
            message = ME.message;
            splitted_message = split(message,'"');
            unknown_param = splitted_message{2};
            assignin("base","Input_Params_Description",Input_Params_Description)
            Input_Params_Description
            error(['未定义','参数 "',unknown_param,'" 。','所有需要输入的参数及其解释存储在工作区的Input_Params_Description中，请核对。'])
        end
    end
end