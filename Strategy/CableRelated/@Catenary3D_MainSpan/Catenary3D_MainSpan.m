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
            % 将外部输入的参数，转换为找形算法内部所定义的算法格式
            % 重要的转换：
            %   1. 坐标系转换：
            %       1.1 y方向和z方向的转换
            %       1.2 坐标原点的平移：以PointA为坐标原点
            %   2. 参数名转换：
            %       1.1
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
                                      'z_Om','';...
                                      'Init_var',''};
            try % 必填参数
                % 参数转换： Params中存储的各种参数转换到Params_converted中
                % Params是主程序中存储起来的，其参数名及其解释在变量InputParamsDescription中
                % Params_converted是obj.AlgoHandle需要输入的参数名

                % 以下是需要输入到找形程序的
                P_x_converted = P_x(2:end-1);
                P_y_converted = -P_y(2:end-1);
                P_z_converted = -P_z(2:end-1);

                % 计算点上的作用力
                Params_converted.P_x            = P_x(2:end-1);
                Params_converted.P_y            = -P_y(2:end-1);
                Params_converted.P_z            = -P_z(2:end-1);
                
                % 吊点上的作用力
                Params_converted.P_hanger_x     = Params.P_force_x;
                Params_converted.P_hanger_y     = -Params.P_force_y;
                Params_converted.P_hanger_z     = -Params.P_force_z;
                
                % PointA在Algo中的坐标，因为PointA是开始计算点，所以坐标一定是[0,0,0]
                Params_converted.x_A             = 0;
                Params_converted.y_A             = 0;
                Params_converted.z_A             = 0;
                
                % PointB在Algo中的坐标
                Params_converted.x_B             = Params.coord_B(1) - Params.coord_A(1);
                Params_converted.y_B             = Params.coord_A(2) - Params.coord_B(2);
                Params_converted.z_B             = Params.coord_A(3) - Params.coord_B(3);

                % 跨中点坐标
                Params_converted.z_Om            = Params.coord_A(3) - Params.z_Om;
                
                % 其他参数
                Params_converted.q_cable        = Params.q;
                Params_converted.n              = Params.n;
                Params_converted.Li             = Params.L;
                Params_converted.E_cable        = Params.E;
                Params_converted.A_cable        = Params.A;
                Params_converted.m              = Params.m;
                Params_converted.l_span         = Params.l_span;
                Params_converted.Index_Hanger   = Params.Index_Hanger;
                Params_converted.n_hanger       = sum(Params.Index_Hanger);
                Params_converted.l_girder_seg   = mean(Params.L);

                Params_converted.coord_A        = Params.coord_A;
                Params_converted.coord_B        = Params.coord_B;

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
            % 可选参数
            if isfield(Params,'Init_var')
                Params_converted.Init_var       = Params.Init_var;
            else
                Params_converted.Init_var       = [];
            end
            
        end
        function Output = action(obj,Params,P_x,P_y,P_z)
            % 将外部参数转换为AlgoHangdle的内部参数
            [Params_converted,P_x_converted,P_y_converted,P_z_converted] = obj.InputParamsAdaptor(Params,P_x,P_y,P_z);
            
            % AlgoHandle
            [X,Y,Z,Epsilon_Init,S,H,alpha,a,x,F_x] = obj.AlgoHandle(Params_converted,P_x_converted,P_y_converted,P_z_converted);% 这里得到的X,Y,Z均为以0点为第一个点，所以需要把XYZ变换
            
            % 将AlgoHandle的内部参数转换为外部参数
            [X,Y,Z] = obj.moveToPosition(Params,X,Y,Z);

            % 需要把所有Algo输出的东西全部放在Output这个struct里面，因为不同的Algo可能输出不同的东西
            Output = struct;
            Output.X = X;
            Output.Y = Y;
            Output.Z = Z;
            Output.Strain = Epsilon_Init;
            Output.UnstressedLength = S;
            Output.H = H;
            Output.alpha = alpha;
            Output.a = a;
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

            % 1. 计算点坐标：坐标系转换 + 左端点平移到PointA
            cal_X = Params.coord_A(1) + cal_X;
            cal_Y = Params.coord_A(2) - cal_Y;
            cal_Z = Params.coord_A(3) - cal_Z;
            
            % 2.. 误差分配：右端点和PointB之间的误差，按照X分配
            allocationRatio = abs((cal_X-cal_X(1))./(cal_X(end)-cal_X(1)));% 根据X坐标确定误差分配比例
            X = cal_X + (Params.coord_B(1)-cal_X(end)).*allocationRatio;
            Y = cal_Y + (Params.coord_B(2)-cal_Y(end)).*allocationRatio;
            Z = cal_Z + (Params.coord_B(3)-cal_Z(end)).*allocationRatio;
        end
    end
end