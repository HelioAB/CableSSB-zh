function solveHangerTopCoord(obj,hanger)
    cable = hanger.findConnectStructureByClass('Cable');

    point_hanger_cable = hanger.findCablePoint;
    point_coord_0 = point_hanger_cable.Coord;
    X0 = point_coord_0(:,1)';
    Y0 = point_coord_0(:,2)';
    Z0 = point_coord_0(:,3)';
    Coord_0 = [X0,Y0,Z0];
    
    % Newton法
    tol = 1e-5;
%             options.Axes = ax;
%             options.Figure = fig;
%             result_cell = obj.solveHangerTopP_NewtonMethod(hanger,cable,tol);
%             assignin("base","result_cell",result_cell)
%             [Coord_X_1,Coord_Y_1,Coord_Z_1] = obj.solveHangerTopP_fsolve(hanger,cable,X0,Y0,Z0,0.01)
    obj.solveHangerTopP_fsolve(hanger,cable)
%             obj.solveHangerTopP_fsolve(hanger,cable,tol)
end

function result_cell = solveHangerTopP_NewtonMethod(obj,hanger,cable,tol)
    arguments
        obj
        hanger
        cable
        tol
    end

%             x0 = -hanger.Params.P_cable_x;% hanger.Params.P_cable_x是吊杆受力，P_X_k0是吊杆作用在cable上的施力
%             y0 = -hanger.Params.P_cable_y;
%             z0 = -hanger.Params.P_cable_z;
    IterAmount = 50;
    result_cell = cell(1,IterAmount);
    cable_A_coord = cable.PointA.Coord;
    cable_B_coord = cable.PointB.Coord;
    mid_coord = (cable_A_coord+cable_B_coord)/2;
    hanger_coord = hanger.findGirderPoint.Coord;
    y_hanger = mean(hanger_coord(:,2));
    z_hanger = mean(hanger_coord(:,3));
    [~,sign_cable_tension] = hanger.getHangerTensionDirectionAtCable();
    z0 = -hanger.Params.P_cable_z;
    y0 = z0*(y_hanger-mid_coord(2))/(z_hanger-mid_coord(3));
    x0 = -ones(size(z0)).*sign_cable_tension(:,1)';
    result_struct.xi = x0;
    result_struct.yi = y0;
    result_struct.zi = z0;

%             assignin("base","P_Y_k0",P_Y_k0)

    [f0_x,f0_y,f0_z,result_struct] = obj.solveHangerTopP_Newton_f(hanger,cable,x0,y0,z0,result_struct);
    x1 = -hanger.Params.P_cable_x;% hanger.Params.P_cable_x是吊杆受力，P_X_k0是吊杆作用在cable上的施力
    y1 = -hanger.Params.P_cable_y;
    z1 = -hanger.Params.P_cable_z;
    result_struct.fi_x = f0_x;
    result_struct.fi_y = f0_y;
    result_struct.fi_z = f0_z;
    
    iter_count = 1;
    result_cell{iter_count} = result_struct;
%             P_Z_k1 = -hanger.Params.P_cable_z;% cable的受力 = hanger的施力 = -hanger的受力
%             P_X_k1 = ones(size(P_Z_k1));
%             % 设置初值
%             cable_A_coord = cable.PointA.Coord;
%             cable_B_coord = cable.PointB.Coord;
%             mid_coord = (cable_A_coord+cable_B_coord)/2;
%             hanger_coord = hanger.findGirderPoint.Coord;
%             y_hanger = mean(hanger_coord(:,2));
%             z_hanger = mean(hanger_coord(:,3));
%             P_Y_k1 = -abs(P_Z_k1*(mid_coord(2)-y_hanger)/(mid_coord(3)-z_hanger)).*sign_cable_tension(:,2)';
%             P_X_k1 = -ones(size(P_Z_k1)).*sign_cable_tension(:,1)';

    eps_x = 1;
    eps_y = 1;
    eps_z = 1;
    while (norm(eps_x)>tol || norm(eps_y)>tol || norm(eps_z)>tol) && iter_count<=IterAmount
        iter_count = iter_count+1;
        [f1_x,f1_y,f1_z,result_struct] = obj.solveHangerTopP_Newton_f(hanger,cable,x1,y1,z1,result_struct);
        result_struct.xi = x1;
        result_struct.yi = y1;
        result_struct.zi = z1;
        result_struct.fi_x = f1_x;
        result_struct.fi_y = f1_y;
        result_struct.fi_z = f1_z;
        result_cell{iter_count} = result_struct;

        % x2 = x1 - f(x1)*(x1-x0)/(f(x1)-f(x0))
        assignin("base","y1",y1)
        assignin("base","y0",y0)
        assignin("base","f1_y",f1_y)
        assignin("base","f0_y",f0_y)
        if isnan(max(abs((x1 - x0)./(f1_x - f0_x)))) % 如果X方向的力很小，就排除，否则会出现奇异值
            x2 = x1;
        else
            x2 = x1 - f1_x .* (x1 - x0) ./ (f1_x - f0_x);
        end
        if isnan(max(abs((x1 - x0)./(f1_x - f0_x)))) % 如果X方向的力很小，就排除，否则会出现奇异值
            y2 = y1;
        else
            y2 = y1 - f1_y .* (y1 - y0) ./ (f1_y - f0_y);
        end
        z2 = z1 - f1_z .* (z1 - z0) ./ (f1_z - f0_z);
        
        % 更新
        x0 = x1;
        x1 = x2;
        y0 = y1;
        y1 = y2;
        z0 = z1;
        z1 = z2;

        f0_x = f1_x;
        f0_y = f1_y;
        f0_z = f1_z;

        eps_x = x1 - x0;
        eps_y = y1 - y0;
        eps_z = z1 - z0;
        assignin("base","eps_z",eps_z)
        assignin("base","eps_x",eps_x)
        assignin("base","eps_y",eps_y)
        assignin("base","iter_count",iter_count)
    end

end

function [delta_x,delta_y,delta_z,result_struct] = solveHangerTopP_Newton_f(obj,hanger,cable,P_cable_x0,P_cable_y0,P_cable_z0,result_struct)
    % 输入：cable的受力，第i次迭代
    % 输出：cable的受力，第i+1次迭代
    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,P_cable_x0,P_cable_y0,P_cable_z0);
    output = cable.findShape(P_x,P_y,P_z);
    result_struct.cable1 = cable.clone;
    cable_coord_0 = cable.Point.Coord;
    index = [false,cable.Params.Index_Hanger,false];
    coord_x_0 = cable_coord_0(index,1);
    coord_y_0 = cable_coord_0(index,2);
    coord_z_0 = cable_coord_0(index,3);

    P_girder_z = hanger.Params.P_girder_z;
    [P_hanger_x1,P_hanger_y1,P_hanger_z1] = hanger.getP(P_girder_z);% hanger.getP输出hanger的受力
    P_X_1 = -P_hanger_x1;% cable的受力 = hanger的施力 = -hanger的受力
    P_Y_1 = -P_hanger_y1;
    P_Z_1 = -P_hanger_z1;

    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,P_X_1,P_Y_1,P_Z_1);
    output = cable.findShape(P_x,P_y,P_z);


    result_struct.cable2 = cable.clone;

    cable_coord_1 = cable.Point.Coord;
    coord_x_1 = cable_coord_1(index,1);
    coord_y_1 = cable_coord_1(index,2);
    coord_z_1 = cable_coord_1(index,3);
    
    delta_x = (coord_x_1-coord_x_0)';
    delta_y = (coord_y_1-coord_y_0)';
    delta_z = (coord_z_1-coord_z_0)';
end
function solveHangerTopP_fsolve(obj,hanger,cable)
    cable_A_coord = cable.PointA.Coord;
    cable_B_coord = cable.PointB.Coord;
    mid_coord = (cable_A_coord+cable_B_coord)/2;
    hanger_coord = hanger.findGirderPoint.Coord;
    y_hanger = mean(hanger_coord(:,2));
    z_hanger = mean(hanger_coord(:,3));
    P_Z_0 = -hanger.Params.P_cable_z;
    P_Y_0 = ones(size(P_Z_0))*(y_hanger-mid_coord(2))/(z_hanger-mid_coord(3));
    P_X_0 = zeros(size(P_Z_0));

    con1 = container();
    con1.List = cable;
    con1.P_Y_0 = P_Y_0;
    fun = @(P_Y_0) obj.solveHangerTopY_ObjFun(P_X_0,P_Y_0,P_Z_0,hanger,cable,con1);
    [P,eps,~,output] = fsolve(fun,P_Y_0);
    assignin("base","P",P)
    assignin("base","eps",eps)
    assignin("base","output",output)
    assignin("base","con1",con1)

end
function solveHangerTopP_fmincon(obj,hanger,cable,tol)
    cable_coord_0 = cable.Point.Coord;
    index = [false,cable.Params.Index_Hanger,false];
    coord_x_0 = cable_coord_0(index,1);
    coord_y_0 = cable_coord_0(index,2);
    coord_z_0 = cable_coord_0(index,3);

    fun = @(P) obj.solveHangerTopP_ObjFun(P,hanger,cable,tol);
    [P,eps] = fsolve(fun,P_0);
    assignin("base","P",P)
    assignin("base","eps",eps)
end
function eps = solveHangerTopP_ObjFun(obj,P,hanger,cable,tol)
    len = length(P);
    P_X_0 = P(1:len/3);
    P_Y_0 = P(1+len/3:2*len/3);
    P_Z_0 = P(2*len/3+1:end);

    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,P_X_0,P_Y_0,P_Z_0);
    output = cable.findShape(P_x,P_y,P_z);

    cable_coord_0 = cable.Point.Coord;
    index = [false,cable.Params.Index_Hanger,false];
    coord_x_0 = cable_coord_0(index,1);
    coord_y_0 = cable_coord_0(index,2);
    coord_z_0 = cable_coord_0(index,3);

    P_girder_z = hanger.Params.P_girder_z;
    [P_hanger_x1,P_hanger_y1,P_hanger_z1] = hanger.getP(P_girder_z);% hanger.getP输出hanger的受力
    P_X_1 = -P_hanger_x1;% cable的受力 = hanger的施力 = -hanger的受力
    P_Y_1 = -P_hanger_y1;
    P_Z_1 = -P_hanger_z1;

    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,P_X_1,P_Y_1,P_Z_1);
    output = cable.findShape(P_x,P_y,P_z);

    cable_coord_1 = cable.Point.Coord;
    coord_x_1 = cable_coord_1(index,1);
    coord_y_1 = cable_coord_1(index,2);
    coord_z_1 = cable_coord_1(index,3);

    eps_x = coord_x_1-coord_x_0;
    eps_y = coord_y_1-coord_y_0;
    eps_z = coord_z_1-coord_z_0;

    eps = [eps_x',eps_y',eps_z'];
    assignin("base","P",P)
    assignin("base","eps",eps)
end


function delta_P_Y = solveHangerTopY_ObjFun(obj,P_X_0,P_Y_0,P_Z_0,hanger,cable,container)
    [P_x,P_y,P_z] = cable.P(cable.Params.Index_Hanger,P_X_0,P_Y_0,P_Z_0);
    output = cable.findShape(P_x,P_y,P_z);
    
    container.List = [container.List,cable.clone];
    P_girder_z = hanger.Params.P_girder_z;
    [~,P_hanger_y1,~] = hanger.getP(P_girder_z);% hanger.getP输出hanger的受力
    P_Y_1 = -P_hanger_y1;
    container.P_Y_1 = [container.P_Y_1;P_Y_1];
    container.P_Y_0 = [container.P_Y_0;P_Y_0];
    delta_P_Y = P_Y_1-P_Y_0;
end