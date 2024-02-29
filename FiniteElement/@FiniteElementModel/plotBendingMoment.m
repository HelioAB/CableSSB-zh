function line_handle = plotBendingMoment(obj,options) % 未完成
    arguments
        obj
        options.Direction (1,3) = [0,1,0] % 矩矢量的方向，默认为整体坐标系的Y方向
        options.Scale (1,1) = -1e-7
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
        options.ColorMap (256,3) = jet % 一个colormap，是256*3的矩阵
    end
    len = length(obj);
    normal_moment = [0,1,0];% 弯矩平面X-Z的法线
    elements = obj.Element;
    [~,Comp_y,Comp_z] = elements.getLocalCoordSystemComponent(normal_moment);% 获得法线向单元坐标系y和z轴的投影
    M_i = zeros(1,len);
    M_j = zeros(1,len);
    inode = Node.empty;
    inode(1,len).Num = [];
    jnode = Node.empty;
    jnode(1,len).Num = [];
    for i=1:len
        element = elements(i);
        force_vector = element.AnsysForceResult;
        Myi = force_vector(5);
        Mzi = force_vector(6);
        Myj = force_vector(11);
        Mzj = force_vector(12);
        M_i(i) = Myi*Comp_y(i) + Mzi*Comp_z(i);
        M_j(i) = Myj*Comp_y(i) + Mzj*Comp_z(i);
        inode(i) = element.INode;
        jnode(i) = element.JNode;
    end
    StartNodes_X = [[inode.X],[jnode.X]];
    StartNodes_Y = [[inode.Y],[jnode.Y]];
    StartNodes_Z = [[inode.Y],[jnode.Z]];
    M = [M_i,M_j];
    EndNodes_X = StartNodes_X + options.Scale*options.Direction(1)*M;
    EndNodes_Y = StartNodes_Y + options.Scale*options.Direction(2)*M;
    EndNodes_Z = StartNodes_Z + options.Scale*options.Direction(3)*M;

    X = [StartNodes_X;EndNodes_X];
    Y = [StartNodes_Y;EndNodes_Y];
    Z = [StartNodes_Z;EndNodes_Z];

    figure(options.Figure) % 将options.Figure设置为当前图窗
    hold(options.Axis,'on')
    line_handle = plot3(options.Axis,X,Y,Z,'Color','r');
    view(3);
end