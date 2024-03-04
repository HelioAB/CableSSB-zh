function [X,Y,Z,Epsilon_Init,S,H,alpha,optim_var,F_x] = Algo_Catenary3D_MainSpan(Params,P_x,P_y,P_z)
    % 输入:
%             Params是一个struct数据,里面存储了以下需要的参数:
%             Params.n              = n;            % 计算节点数，不包括两个塔顶IP点
%             Params.P_hanger_x     = -P_hanger_x;  % x方向（顺桥向）吊杆力，全局坐标系的-X方向为正，向量长度n_hanger，单位N
%             Params.P_hanger_y     = -P_hanger_y;  % y方向（横桥向）吊杆力，全局坐标系的-Y方向为正，向量长度n_hanger，单位N
%             Params.P_hanger_z     = -P_hanger_z;  % z方向（竖向）吊杆力，全局坐标系的-Z方向为正，向量长度n_hanger，单位N
%             Params.n_hanger       = length(P_z);  % 吊杆数
%             Params.q_cable        = q_cable;      % 主缆的重力荷载集度，单位N/m
%             Params.E_cable        = E_cable;      % 主缆弹模，单位Pa
%             Params.A_cable        = A_cable;      % 主缆面积，单位m^2
%             Params.m              = ceil(n/2);    % 跨中节点编号, ceil(n/2)
%             Params.l_span         = l_span;       % 跨径，单位m
%             Params.Li             = Li;           % 每段悬链线的水平投影长度组成的向量，向量长度n+1
%             Params.d0             = (y_B-y_A);    % y_A：A点的横桥向坐标；y_B:B点的横桥向坐标
%             Params.l_girder_seg   = mean(L);      % 每个节段的平均长度，仅用于初始化线形，不需要太精确。在初始化线形中用来计算一个节段的主梁的自重
%             Params.y_d_m          = (y_A+y_B)/2;  % 主缆中点横桥向坐标，仅用于初始化线形，不需要太精确
%             Params.hA             = hA            % 主缆A点的高度
%             Params.hB             = hB            % 主缆B点的高度
%             Params.hOm            = hOm;          % 主缆跨中点Om的高度
%             P_x                   = P_x;         % 所有计算节点的x方向（顺桥向）力，全局坐标系的-X方向为正，向量长度n，单位N
%             P_y                   = -P_y;
%             P_z                   = -P_z;

%     输出:
%           X: 包括两个塔顶IP点在内的, 所有节点x坐标向量, 向量长度n+2, 单位m
%           Y: 包括两个塔顶IP点在内的, 所有节点y坐标向量, 向量长度n+2, 单位m
%           Z: 包括两个塔顶IP点在内的, 所有节点z坐标向量, 向量长度n+2, 单位m
%           Epsilon_Init: 初应变向量, 向量长度n+1, 单位m
%           S: 无应力长度向量, 向量长度n+1, 单位m
%           H: 水平力向量, 向量长度n+1, 单位N
%           alpha: 主缆分段在水平面上投影与顺桥向夹角
%           opti_var: 设计变量，[H,alpha,a]
%           F_x: 主缆水平力的顺桥向分力,提供给边跨找形程序,保证边跨和中跨的F_x相同,单位N

    % 加载所有计算参数,避免本函数需要输入过多参数
    q_cable = Params.q_cable;
    n = Params.n;
    Li = Params.Li;
    E_cable = Params.E_cable;
    A_cable = Params.A_cable;
    % 将P_x、P_y、P_z存储到Params中，方便各种函数取用
    Params.P_x = P_x;
    Params.P_y = P_y;
    Params.P_z = P_z;

    %% 1. 优化问题参数的设置
    % 1.1 设计变量初值的设定
    % 水平力的初始值H通过抛物线确定，a1初始值为0。
    init_var = Init_var(Params);
    
    % 1.2 设置线性约束
    % 线性不等式约束 Ax <= b
    % 设置 H >= 0和 alpha >= 0 
    % bug战场,因为很早以前设置的alpha>=0这个约束条件,耗费了很多时间进行debug,实际上alpha没有>=0的约束条件,alpha<0也行
    A = [-1,0,0;0,0,0;0,0,0];
    b = [0;0;0];
    
    % 1.3 优化算法的选择
    % options = optimoptions('fmincon','Display','iter','Algorithm','sqp');

    %% 2. 优化函数的调用
    
    % 2.1 非线性约束优化函数fmincon()函数的参数设置
    fun = @(var)ObjectFun3D(var,Params);
    A;
    b;
    Aeq = [];
    beq = [];
    lb = [];
    ub = [];
    nonlcon = [];
    init_var;

%     options = optimoptions('fmincon','Display','iter-detailed','Algorithm','sqp','ObjectiveLimit',1e-10); % 展示迭代过程
    options = optimoptions('fmincon','Display','None','ObjectiveLimit',1e-6); % 展示迭代过程
    
    % 2.2 调用fmincon函数
    % 为什么不用fminimax、fgoalattain等多目标优化程序？因为这些程序对初始点敏感，而fmincon会自己重新选点
    [optim_var,fval,exitflag,output] = fmincon(fun,init_var,A,b,Aeq,beq,lb,ub,nonlcon,options); % 默认使用 内点法
    % 2.2.1 使用sqp算法(顺序二次规划)的fmincon()
    % options = optimoptions('fmincon','Display','iter-detailed','Algorithm','sqp','ObjectiveLimit',1e-7,'OptimalityTolerance',1e-15,'StepTolerance',1e-15);
    % [x,fval,exitflag,output] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
    % SQP顺序二次规划算法最后得到的fval比内点法得到的fval大
    % 当n=100时,SQP: fval=1.04; 内点法: fval=1.4e-9

    %% 3. 生成悬链线各节点坐标XYZ位置、水平力H、无应力长度S、初应变ε
    [Xi,Yi,Zi,H,alpha,S,Epsilon_Init] = Seg_catenary(q_cable,n,Li,P_x,P_y,P_z,optim_var,E_cable,A_cable); 
    % 当中XYZ的正负号规定：
    % X: 正向为全局坐标系的正X
    % Y: 正向为全局坐标系的负Y
    % Z: 正向为全局坐标系的负Z
    % 全局坐标系满足右手系
    
    % 初始化坐标向量
    X = zeros([1,length(Xi)+1]);
    Y = zeros([1,length(Yi)+1]);
    Z = zeros([1,length(Zi)+1]);
    
    for i=2:length(X)
        X(i) = Xi(i-1) + X(i-1);
        Y(i) = Yi(i-1) + Y(i-1);
        Z(i) = Zi(i-1) + Z(i-1);
    end

    F_x = H(1)*cos(alpha(1));

end

%% 一端悬链线的各种参数计算
function [Xi,Yi,Zi,H,alpha,S,Epsilon_Init] = Seg_catenary(q_cable,n,Li,P_x,P_y,P_z,var,E_cable,A_cable)
    % 输入:
    arguments
        q_cable {mustBeNumeric} % 
        n {mustBeNumeric}
        Li (1,:)
        P_x (1,:)
        P_y (1,:)
        P_z (1,:)
        var (:,:)
        E_cable (1,1) double
        A_cable (1,1) double
    end

    % 主缆自重q_cable，单位N/m
    % 节点数目n
    % Li为每个悬链线分段的水平长度组成的向量，length(Li) == n+1
    % 吊杆拉力P，P中每个元素表示第i根吊杆的拉力P_i，length(P) == n
    
    % 计算主跨时, 待求未知水平力H. 计算边跨时,H已知. 单位N
    % 待求未知参数a1

    H = zeros(1,n+1);
    alpha = zeros(1,n+1);
    tan_alpha = zeros(1,n+1);
    a = zeros(1,n+1);
    
    alpha(1) = var(2);
    tan_alpha(1) = tan(var(2));
    a(1) = var(3);
    H(1) = var(1);

    Xi = Li; % 因为xi为局部坐标系中的x坐标，因此，如果向量Xi是：在以O_i为原点建立的坐标系X_i-Y_i上，O_i+1的水平坐标xi所组成的向量...
            % ...那么向量Xi在数值上就等于Li
            % length(Xi) == n+1

    Yi = zeros([1,n+1]);% length(Yi) == n+1
                        % Yi中每个元素为每个分段悬链线的横桥向距离
           
    Zi = zeros([1,n+1]); % 初始化Zi向量，向量Zi中的第i个元素是z_i
                         % length(Zi) == n+1
                         % Zi中每个元素为每个分段悬链线的高差

    for i = 1:n % 遍历每一段悬链线
            [H_i1,alpha_i1,a_i1,tan_alpha_i1] = Iter_x_3D(H(i),alpha(i),a(i),P_x(i),P_y(i),P_z(i),Xi(i),q_cable);
    
            H(i+1) = H_i1;
            alpha(i+1) = alpha_i1;
            tan_alpha(i+1) = tan_alpha_i1;
            a(i+1) = a_i1; 
    end
    c = -H/q_cable;
    Yi = Xi.*tan_alpha;
    Zi = c.*cosh(Xi./(c.*cos(alpha))+a) - c.*cosh(a);

    S_force = c.*(sinh(Li./c./cos(alpha)+a)-sinh(a)); % 有应力长度
    S =  S_force - H/2/E_cable/A_cable.*(Li./cos(alpha)+c/2.*(sinh(2*(Li./c./cos(alpha)+a))-sinh(2*a))); %无应力长度
    Epsilon_Init = (S_force - S) ./ S; % 初应变
end

%% 参数迭代
function [H_i1,alpha_i1,a_i1,tan_alpha_i1] = Iter_x_3D(H_i,alpha_i,a_i,P_xi,P_yi,P_zi,l_i,q_cable)
        % alpha_i+1
        tan_alpha_i1 = (H_i*sin(alpha_i)-P_yi)/(H_i*cos(alpha_i));
        alpha_i1 = atan(tan_alpha_i1);
        % H_i+1
        H_i1 = (H_i*cos(alpha_i)-P_xi)/cos(alpha_i1);
        % a_i+1
        c_i = -H_i/q_cable;
        a_i1 = asinh((H_i*sinh(l_i/(c_i*cos(alpha_i)) + a_i)- P_zi)/H_i1); 
end

%% 优化的目标函数
function f = ObjectFun3D(var,Params)

    q_cable = Params.q_cable;
    n = Params.n;
    Li = Params.Li;
    P_x= Params.P_x;
    P_y = Params.P_y;
    P_z = Params.P_z;
    E_cable = Params.E_cable;
    A_cable = Params.A_cable;
    hA = Params.hA;
    hB = Params.hB;
    hOm = Params.hOm;
    d0 = Params.d0;
    m = Params.m;
    
    [~,Yi,Zi] = Seg_catenary(q_cable,n,Li,P_x,P_y,P_z,var,E_cable,A_cable); 
    f1 = sum(Zi)-(hA-hB); % 为什么不是hB-hA? 因为h的方向与z的方向相反

    f2 = sum(Zi(1:m)) - (hA-hOm);

    f3 = sum(Yi) - d0; % d0 = y_B - y_A而不是y_A - y_B
    f = f1^2 + f2^2 + f3^2; % 目标函数
end

%% 初始化线形
function var = Init_var(Params)
    n_hanger = Params.n_hanger;
    y_d_m = Params.y_d_m;
    l_span = Params.l_span;
    hA = Params.hA;
    hB = Params.hB;
    hOm = Params.hOm;
    q_cable = Params.q_cable;
    P_hanger_z = Params.P_hanger_z;
    P_hanger_y = Params.P_hanger_y;
    l_girder_seg = Params.l_girder_seg;
    
    % H
    f = (hA+hB)/2 - hOm; % 垂度f,注意这个f与ObjectFun里面的f意义不同
    if n_hanger == 0
        H = (q_cable/8*l_span^2) /f; % 没有吊杆力的情况
    elseif n_hanger == 1
        H = (q_cable/8*l_span^2 + 2*sum(P_hanger_z)*l_span/4) /f; % 只有一根吊杆力的情况
    elseif n_hanger >= 2
        D = l_girder_seg * (n_hanger-1); % 吊杆区长度D
        q_hanger = 2*sum(P_hanger_z)/D;
        H = (q_hanger*D/4*(l_span-D) + q_hanger*D^2/8 + q_cable/8*l_span^2) / f;
    end
    
    % alpha
    if n_hanger == 0
        alpha1 = 0; % 没有吊杆的情况
    elseif n_hanger == 1
        alpha1 = atan(sum(P_hanger_y)/sum(P_hanger_z)); % 有吊杆的情况
    elseif n_hanger >= 2
        alpha1 = atan(sum(P_hanger_y)/sum(P_hanger_z)); % 有吊杆的情况
    end
    
    % a
    c = -H/q_cable;  
    a1 = -10*l_span/(2*c);

    var = [H,alpha1,a1];
end