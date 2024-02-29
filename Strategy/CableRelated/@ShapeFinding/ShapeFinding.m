classdef ShapeFinding < Strategy
    properties
        ExtraParams
    end
    methods
        [Params_converted,P_x_converted,P_y_converted,P_z_converted] = ParamsAdaptor(obj,Params,P_x,P_y,P_z)
        Output = action(obj,Params,P_x,P_y,P_z)
        [X,Y,Z] = moveToPosition(obj,Params,cal_X,cal_Y,cal_Z)
    end
end