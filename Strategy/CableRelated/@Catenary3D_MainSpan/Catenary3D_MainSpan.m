classdef Catenary3D_MainSpan < ShapeFinding
    % 如果要修改找形方法，只需要
    % 1. 新建一个继承自ShapeFinding的类
    % 2. 修改算法函数的函数句柄
    % 3. 在下面重载ParamsAdaptor方法
    % 4. 修改findShape()方法的输出
    methods
        function obj = Catenary3D_MainSpan()
            obj.AlgoHandle = @Algo_Catenary3D_MainSpan; % 修改算法函数的函数句柄
        end
        function [Params_converted,P_x_converted,P_y_converted,P_z_converted] = InputParamsAdaptor(obj,Params,P_x,P_y,P_z)
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
                                      'coord_B','';...
                                      'hOm',''};
            try
                % 参数转换： Params中存储的各种参数转换到Params_converted中
                % Params是主程序中存储起来的，其参数名及其解释在变量InputParamsDescription中
                % Params_converted是obj.AlgoHandle需要输入的参数名
                P_x_converted                   = P_x(2:end-1); % 原始的P_x:整体坐标系
                P_y_converted                   = -P_y(2:end-1);
                P_z_converted                   = -P_z(2:end-1);
                x_A = Params.coord_A(1);
                y_A = Params.coord_A(2);
                z_A = Params.coord_A(3);
                x_B = Params.coord_B(1);
                y_B = Params.coord_B(2);
                z_B = Params.coord_B(3);

                % 以下是需要输入到找形程序的
                Params_converted.P_x            = P_x_converted;
                Params_converted.P_y            = P_y_converted;
                Params_converted.P_z            = P_z_converted;
                Params_converted.P_hanger_x     = -Params.P_force_x;
                Params_converted.P_hanger_y     = -Params.P_force_y;
                Params_converted.P_hanger_z     = -Params.P_force_z;
                Params_converted.q_cable        = Params.q;
                Params_converted.n              = Params.n;
                Params_converted.Li             = Params.L;
                Params_converted.E_cable        = Params.E;
                Params_converted.A_cable        = Params.A;
                Params_converted.hA             = z_A;
                Params_converted.hB             = z_B;
                Params_converted.m              = Params.m;
                Params_converted.l_span         = Params.l_span;
                Params_converted.d0             = (y_B-y_A);
                Params_converted.n_hanger       = length(P_z);
                Params_converted.l_girder_seg   = mean(Params.L);
                Params_converted.y_d_m          = (y_A+y_B)/2;
                Params_converted.coord_A        = Params.coord_A;
                Params_converted.coord_B        = Params.coord_B;
                Params_converted.hOm            = Params.hOm;

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
            [Params,P_x,P_y,P_z] = obj.InputParamsAdaptor(Params,P_x,P_y,P_z);

            [X,Y,Z,Epsilon_Init,S,H,alpha,x,F_x] = obj.AlgoHandle(Params,P_x,P_y,P_z);% 这里得到的X,Y,Z均为以0点为第一个点，所以需要把XYZ变换
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
            Output.x = x;
            Output.F_x = F_x;
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
            
            cal_X = Params.coord_A(1) + cal_X;
            cal_Y = Params.coord_A(2) - cal_Y;
            cal_Z = Params.coord_A(3) - cal_Z;

            x_tol = tolerance_B(1);
            y_tol = tolerance_B(2);
            z_tol = tolerance_B(3);

            coord_B = Params.coord_B;
            x_B = coord_B(1);
            y_B = coord_B(2);
            z_B = coord_B(3);

            allocationRatio = abs((cal_X-cal_X(1))./(cal_X(end)-cal_X(1)));
                X = cal_X + (x_B-cal_X(end)).*allocationRatio;
                Y = cal_Y + (y_B-cal_Y(end)).*allocationRatio;
                Z = cal_Z + (z_B-cal_Z(end)).*allocationRatio;
%             if abs(x_B-cal_X(end)) < x_tol
%                 X = cal_X + (x_B-cal_X(end)).*allocationRatio;
%             else
%                 warning('计算X的最后一个坐标与设计X的差距大于tolerance')
%             end
%             if abs(y_B-cal_Y(end)) < y_tol
%                 Y = cal_Y + (y_B-cal_Y(end)).*allocationRatio;
%             else
%                 warning('计算Y的最后一个坐标与设计Y的差距大于tolerance')
%             end
%             if abs(z_B-cal_Z(end)) < z_tol
%                 Z = cal_Z + (z_B-cal_Z(end)).*allocationRatio;
%             else
%                 warning('计算Z的最后一个坐标与设计Z的差距大于tolerance')
%             end
        end
    end
end