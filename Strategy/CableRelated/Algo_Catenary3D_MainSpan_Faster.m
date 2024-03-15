function [X,Y,Z,Epsilon_Init,S,H,alpha,a,optim_var,F_x] = Algo_Catenary3D_MainSpan_Faster(Params,P_x,P_y,P_z)
    % 加载所有计算参数,避免本函数需要输入过多参数
    q_cable = Params.q_cable;
    E_cable = Params.E_cable;
    A_cable = Params.A_cable;

    %% 0. 仅计算吊点: 相关参数设置
    % 吊点对应的Li
    index = [false,Params.Index_Hanger,false];
    num_Subcatenary = length(index)-1;% 92
    num_Catenary = sum(index)+1;% 23
    L_Subcatenary = Params.Li;
    L_Catenary = zeros(1,num_Catenary);
    count_catenary = 1;
    len_catenary = 0;
    Index_CatenaryInSubcatenary = false(1,num_Subcatenary);
    IndexCell_CatenaryInSubcatenary = cell(1,num_Catenary);
    for i=1:length(index)
        if index(i) % 如果这里是吊点，就将长度赋值给L_Catenary(count)，然后重新计算长度
            % 释放累加的长度
            L_Catenary(count_catenary) = len_catenary;
            len_catenary = L_Subcatenary(i);
            % 
            IndexCell_CatenaryInSubcatenary{1,count_catenary} = Index_CatenaryInSubcatenary;
            Index_CatenaryInSubcatenary = false(1,num_Subcatenary);
            Index_CatenaryInSubcatenary(i) = true;
            %
            count_catenary = count_catenary + 1;
        elseif i==length(index)
            L_Catenary(count_catenary) = len_catenary;
            IndexCell_CatenaryInSubcatenary{count_catenary} = Index_CatenaryInSubcatenary;
        else % 如果这里不是吊点，就累加长度
            len_catenary = len_catenary + L_Subcatenary(i);
            Index_CatenaryInSubcatenary(i) = true;
        end
    end

    Params.Li = L_Catenary;
    Li = L_Catenary;
    % 重新计算：计算点数n（令其等于吊点数）
    Params.n = num_Catenary-1;
    n = Params.n;
    % 重新计算：P_x,P_y,P_z
    index = Params.Index_Hanger;
    P_x = P_x(index);
    P_y = P_y(index);
    P_z = P_z(index);
    
    Params.P_x = P_x;
    Params.P_y = P_y;
    Params.P_z = P_z;


    %% 1. 优化问题参数的设置
    % 1.1 设计变量初值的设定
    % 如果Params中存储了Init_var，就使用它；否则，使用函数Init_var()所给出的初始值。
    if isempty(Params.Init_var)
        init_var = Init_var(Params);
    else
        init_var = Params.Init_var;
    end
    
    % 1.2 设置线性约束
    % 以Ax <= b的形式, 设置线形不等式约束H >= 0
    A = [-1,0,0;0,0,0;0,0,0];
    b = [0;0;0];

    % 1.3 其他参数设置
    fun = @(var)ObjectFun3D(var,Params);
    Aeq = [];
    beq = [];
    lb = [];
    ub = [];
    nonlcon = [];
    options = optimoptions('fmincon','Display','iter-detailed','ObjectiveLimit',1e-4); % 展示迭代过程
    
    % 1.4 调用fmincon函数
    [optim_var,fval,exitflag,output] = fmincon(fun,init_var,A,b,Aeq,beq,lb,ub,nonlcon,options); % 默认使用 内点法

    %% 2. 生成悬链线各节点坐标XYZ位置、水平力H、无应力长度S、初应变ε
    [Xi,Yi,Zi,H,alpha,a,S,Epsilon_Init] = Seg_catenary(q_cable,n,Li,P_x,P_y,P_z,optim_var,E_cable,A_cable);
    % 当中XYZ的正负号规定：
    % X: 正向为全局坐标系的正X
    % Y: 正向为全局坐标系的负Y
    % Z: 正向为全局坐标系的负Z
    % 全局坐标系满足右手系
    
    % 初始化坐标向量
    X_Point = zeros([1,length(Xi)+1]);% +1 是加的PointA
    Y_Point = zeros([1,length(Yi)+1]);
    Z_Point = zeros([1,length(Zi)+1]);
    
    
    for i=2:length(X_Point)
        X_Point(i) = Xi(i-1) + X_Point(i-1);
        Y_Point(i) = Yi(i-1) + Y_Point(i-1);
        Z_Point(i) = Zi(i-1) + Z_Point(i-1);
    end
    F_x = H(1)*cos(alpha(1));
    
    %% 3. 内插计算点
    X = zeros(1,num_Subcatenary+1);
    Y = zeros(1,num_Subcatenary+1);
    Z = zeros(1,num_Subcatenary+1);
    for i=1:num_Catenary
        index_catenary = IndexCell_CatenaryInSubcatenary{i};
        L_SubcatenaryInACatenary = L_Subcatenary(index_catenary);
        
        X_0 = X_Point(i);
        Y_0 = Y_Point(i);
        Z_0 = Z_Point(i);
        
        H_0     = H(i);
        alpha_0 = alpha(i);
        a_0     = a(i);

        c_0     = -H_0/q_cable;
        S_force_0 = c_0.*(sinh(L_SubcatenaryInACatenary(1)./c_0./cos(alpha_0)+a_0)-sinh(a_0)); % 有应力长度
        S_0       =  S_force_0 - H_0/2/E_cable/A_cable.*(L_SubcatenaryInACatenary(1)./cos(alpha_0)+c_0/2.*(sinh(2*(L_SubcatenaryInACatenary(1)./c_0./cos(alpha_0)+a_0))-sinh(2*a_0))); %无应力长度
        Epsilon_Init_0 = (S_force_0 - S_0) ./ S_0; % 初应变

        if length(L_SubcatenaryInACatenary) == 1
            X_interp = X_0;
            Y_interp = Y_0;
            Z_interp = Z_0;
        else
            Delta_X = zeros(1,length(L_SubcatenaryInACatenary)-1);
            for j=1:length(L_SubcatenaryInACatenary)-1
                if j==1
                    Delta_X(1) = L_SubcatenaryInACatenary(1);
                else
                    Delta_X(j) = Delta_X(j-1) + L_SubcatenaryInACatenary(j);
                end
            end
            [Delta_Y,Delta_Z,H_i,alpha_i,a_i,S_i,Epsilon_Init_i] = interpCatenaryPoints(Delta_X,H_0,alpha_0,a_0,L_SubcatenaryInACatenary(2:end),q_cable,E_cable,A_cable);
            X_interp = [X_0, X_0 + Delta_X];
            Y_interp = [Y_0, Y_0 + Delta_Y];
            Z_interp = [Z_0, Z_0 + Delta_Z];
            
            H_interp = [H_0, H_i];
            alpha_interp = [alpha_0, alpha_i];
            a_interp = [a_0, a_i];
            S_interp = [S_0, S_i];
            Epsilon_Init_interp = [Epsilon_Init_0, Epsilon_Init_i];
        end
        assignin("base","X_interp",X_interp)
        assignin("base","Y_interp",Y_interp)
        assignin("base","Z_interp",Z_interp)
        X([index_catenary,false]) = X_interp;
        Y([index_catenary,false]) = Y_interp;
        Z([index_catenary,false]) = Z_interp;
        H([index_catenary,false]) = H_interp;
        alpha([index_catenary,false]) = alpha_interp;
        a([index_catenary,false]) = a_interp;
        S([index_catenary,false]) = S_interp;
        Epsilon_Init([index_catenary,false]) = Epsilon_Init_interp;
        
    end
    X(end) = X_Point(end);
    Y(end) = Y_Point(end);
    Z(end) = Z_Point(end);

end

%% 一端悬链线的各种参数计算
function [Xi,Yi,Zi,H,alpha,a,S,Epsilon_Init] = Seg_catenary(q_cable,n,Li,P_x,P_y,P_z,var,E_cable,A_cable)
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
    % 计算点数目n
    % Li为每个悬链线分段的水平长度组成的向量，length(Li) == n+1
    % 吊杆拉力P，P中每个元素表示第i根吊杆的拉力P_i，length(P) == n
    
    % 计算主跨时, 待求未知水平力H. 计算边跨时,H已知. 单位N
    % 待求未知参数a1


    % H,alpha,a: PointA,吊点1,吊点2,...,吊点n（没有PointB）
    H = zeros(1,n+1);
    alpha = zeros(1,n+1);
    tan_alpha = zeros(1,n+1);
    a = zeros(1,n+1);
    
    alpha(1) = var(2);
    tan_alpha(1) = tan(var(2));
    a(1) = var(3);
    H(1) = var(1);
    
    % Xi,Yi,Zi: 吊点1,吊点2,...,吊点n,PointB（没有PointA）
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
    y_A = Params.y_A;
    y_B = Params.y_B;
    z_A = Params.z_A;
    z_B = Params.z_B;
    z_Om = Params.z_Om;
    if mod(n,2) % 奇数
        m = (n+1)/2;
    else % 偶数
        m = n/2;
    end
    
    [~,Yi,Zi] = Seg_catenary(q_cable,n,Li,P_x,P_y,P_z,var,E_cable,A_cable); 
    
    
    f1 = sum(Zi) - (z_B-z_A);

    f2 = sum(Zi(1:m)) - (z_Om-z_A);

    f3 = sum(Yi) - (y_B-y_A); 

    
    
    f = f1^2 + f2^2 + f3^2; % 目标函数
end

%% 初始化线形
function var = Init_var(Params)
    n_hanger = Params.n_hanger;
    l_span = Params.l_span;
    z_A = Params.z_A;
    z_B = Params.z_B;
    z_Om = Params.z_Om;
    q_cable = Params.q_cable;
    P_hanger_z = Params.P_hanger_z;
    P_hanger_y = Params.P_hanger_y;
    l_girder_seg = Params.l_girder_seg;
    
    % H
    f = z_Om - (z_A+z_B)/2; % 垂度f,注意这个f与ObjectFun里面的f意义不同
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
    % if n_hanger == 0
    %     alpha1 = 0; % 没有吊杆的情况
    % elseif n_hanger == 1
    %     alpha1 = atan(P_hanger_y/P_hanger_z); % 有吊杆的情况
    % elseif n_hanger >= 2
    %     alpha1 = atan(sum(P_hanger_y)/sum(P_hanger_z)); % 有吊杆的情况
    % end
    alpha1 = 0;
    
    % a
    % c = -H/q_cable;  
    % a1 = -10*l_span/(2*c);
    a1 = 0;

    var = [H,alpha1,a1];
end
function [Delta_Y,Delta_Z,H,alpha,a,S,Epsilon_Init] = interpCatenaryPoints(Delta_X,H_0,alpha_0,a_0,Li,q_cable,E_cable,A_cable)
    % 输入：
    % X_0, Y_0, Z_0: 一段悬链线左端点的XYZ坐标
    % Xi: 一段悬链线内部计算点的X坐标（不包含左端点和右端点）
    % H_0, alpha_0, a_0: 一段悬链线左端点的H, alpha, a
    % q: 一段悬链线的每延米自重
    %
    % 输出:
    % Xi,Yi,Zi：悬链线内部计算点的坐标（不包含左端点和右端点）
    % H,alpha,a：内部计算点对应的H, alpha, a（不包含左端点和右端点）
    % S: 无应力长度
    % Epsilon_Init：弹性应变 

    c_0     = -H_0/q_cable;
    
    H       = H_0 + zeros(1,length(Delta_X));
    alpha   = alpha_0 + zeros(size(H));
    a       = a_0 + Delta_X/(c_0*cos(alpha_0));


    Delta_Y = Delta_X* tan(alpha_0);
    Delta_Z = c_0.* cosh(Delta_X./(c_0.*cos(alpha_0)) + a_0) + c_0.*cosh(a_0);
    
    S_force = c_0.*(sinh(Li./c_0./cos(alpha)+a)-sinh(a)); % 有应力长度
    S =  S_force - H/2/E_cable/A_cable.*(Li./cos(alpha)+c_0/2.*(sinh(2*(Li./c_0./cos(alpha)+a))-sinh(2*a))); %无应力长度
    Epsilon_Init = (S_force - S) ./ S; % 初应变
    
end