classdef Catenary3D_SideSpan < ShapeFinding
    % 如果要修改找形方法，只需要
    % 1. 新建一个继承自ShapeFinding的类
    % 2. 修改算法函数的函数句柄
    % 3. 在下面重载ParamsAdaptor方法
    % 4. 修改findShape()方法的输出
    methods
        function obj = Catenary3D_SideSpan()
            obj.AlgoHandle = @Algo_Catenary3D_SideSpan; % 修改算法函数的函数句柄
        end
        function [Params_converted,P_x_converted,P_y_converted,P_z_converted] = ParamsAdaptor(obj,Params,P_x,P_y,P_z)
            % 需要输入的参数的名称与解释
            Input_Params_Description = {'P_force_x','作用于Cable.ForcePoint上的外力的x方向分力';...
                                      'P_force_y','作用于Cable.ForcePoint上的外力的y方向分力';...
                                      'P_force_z','作用于Cable.ForcePoint上的外力的y方向分力';...
                                      'q','Cable的重力荷载集度';...
                                      'n','';...
                                      'L','';...
                                      'E','';...
                                      'A','';...
                                      'm','';...
                                      'l_span','';...
                                      'coord_A','';...
                                      'coord_B','';
                                      'F_x',''};
            try
                % 参数转换： Params中存储的各种参数转换到Params_converted中
                % Params是主程序中存储起来的，其参数名及其解释在变量InputParamsDescription中
                % Params_converted是obj.AlgoHandle需要输入的参数名
                P_x_converted                   = P_x(2:end-1); % 原始的P_x是包含了两个端点的
                P_y_converted                   = -P_y(2:end-1);
                P_z_converted                   = -P_z(2:end-1);
                %
                Params_converted.P_x            = P_x_converted;
                Params_converted.P_y            = P_y_converted;
                Params_converted.P_z            = P_z_converted;
                
                Params_converted.x_A             = Params.coord_A(1);
                Params_converted.y_A             = -Params.coord_A(2);
                Params_converted.z_A             = -Params.coord_A(3);

                Params_converted.x_B             = Params.coord_B(1);
                Params_converted.y_B             = -Params.coord_B(2);
                Params_converted.z_B             = -Params.coord_B(3);

                Params_converted.P_hanger_x     = Params.P_force_x;
                Params_converted.P_hanger_y     = -Params.P_force_y;
                Params_converted.P_hanger_z     = -Params.P_force_z;
                
                Params_converted.q_cable        = Params.q;
                Params_converted.n              = Params.n;
                Params_converted.Li             = Params.L;
                Params_converted.E_cable        = Params.E;
                Params_converted.A_cable        = Params.A;
                Params_converted.m              = Params.m;
                Params_converted.l_span         = Params.l_span;
                Params_converted.n_hanger       = length(P_z);
                Params_converted.l_girder_seg   = mean(Params.L);
                Params_converted.coord_A        = Params.coord_A;
                Params_converted.coord_B        = Params.coord_B;
                Params_converted.F_x            = Params.F_x;

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
        function Output = action(obj,Params,P_x,P_y,P_z)
            % 本方法只负责计算出各种参数，并放在Output中
            [Params,P_x,P_y,P_z] = obj.ParamsAdaptor(Params,P_x,P_y,P_z);
            [X,Y,Z,Epsilon_Init,S,H,alpha,a,x] = obj.AlgoHandle(Params,P_x,P_y,P_z);% 这里得到的X,Y,Z均为以0点为第一个点，所以需要把XYZ变换
            [X,Y,Z] = obj.moveToPosition(Params,X,Y,Z);

            % 需要把所有Algo输出的东西全部放在Output这个struct里面，因为不同的Algo可能输出不同的东西
            Output = struct; % 创建空struct
            Output.X = X;
            Output.Y = Y;
            Output.Z = Z;
            Output.Strain = Epsilon_Init;
            Output.UnstressedLength = S;
            Output.HorizontalForce = H;
            Output.alpha = alpha;
            Output.a = a;
            Output.x = x;
        end
        function [X,Y,Z] = moveToPosition(obj,Params,cal_X,cal_Y,cal_Z,tolerance_B)
            % 找形程序计算误差分配函数
            arguments
                obj
                Params
                cal_X
                cal_Y
                cal_Z
                tolerance_B (1,3) = [1e-3,1e-3,1e-3] % B点与计算XYZ最后一个点的距离小于tolerance的才会抹平这个微小的误差
            end
            
            % 设全局坐标系为 X_global,Y_global,Z_global
            % 主缆线形求解算法中，计算坐标系为：
            % X_cal = X_global
            % Y_cal = -Y_global
            % Z_cal = -Z_global
            x_B = Params.coord_B(1);
            y_B = Params.coord_B(2);
            z_B = Params.coord_B(3);
            
            % 1. 对主缆线形求解算法获得的计算点坐标：坐标系变换
            cal_Y = -cal_Y;
            cal_Z = -cal_Z;
            
            % 2. 计算点坐标：左端点平移到PointA
            cal_X = Params.coord_A(1) + cal_X;
            cal_Y = Params.coord_A(2) + cal_Y;
            cal_Z = Params.coord_A(3) + cal_Z;
            
            % 3. 误差分配：右端点和PointB之间的误差，按照X分配
            allocationRatio = abs((cal_X-cal_X(1))./(cal_X(end)-cal_X(1)));% 根据X坐标确定误差分配比例
            X = cal_X + (Params.coord_B(1)-cal_X(end)).*allocationRatio;
            Y = cal_Y + (Params.coord_B(2)-cal_Y(end)).*allocationRatio;
            Z = cal_Z + (Params.coord_B(3)-cal_Z(end)).*allocationRatio;


            allocationRatio = abs((cal_X-cal_X(1))./(cal_X(end)-cal_X(1)));
            if abs(x_B-cal_X(end)) < tolerance_B(1)
                X = cal_X + (x_B-cal_X(end)).*allocationRatio;
            else
                warning('计算X的最后一个坐标与设计X的差距大于tolerance')
            end
            if abs(y_B-cal_Y(end)) < tolerance_B(2)
                Y = cal_Y + (y_B-cal_Y(end)).*allocationRatio;
            else
                warning('计算Y的最后一个坐标与设计Y的差距大于tolerance')
            end
            if abs(z_B-cal_Z(end)) < tolerance_B(3)
                Z = cal_Z + (z_B-cal_Z(end)).*allocationRatio;
            else
                warning('计算Z的最后一个坐标与设计Z的差距大于tolerance')
            end
            
        end
    end
end