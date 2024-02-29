function [L,E,I,M_i,M_j] = RawDataToInfo(RawData,structure,Map_MatlabLine2AnsysElem)
    num_elem = RawData(:,1);
    E = RawData(:,2);
    Iyy_sec = RawData(:,3);
    Izz_sec = RawData(:,4);
    Iyy_real = RawData(:,5);
    Izz_real = RawData(:,6);
    L = RawData(:,7);
    Myi = RawData(:,8);
    Mzi = RawData(:,9);
    Myj = RawData(:,10);
    Mzj = RawData(:,11);
    
    if isa(structure.ElementType,'Beam4')
        Iyy = Iyy_real;
        Izz = Izz_real;
    else
        Iyy = Iyy_sec;
        Izz = Izz_sec;
    end
    line = structure.Line;
    normal_moment = [0,1,0];% 弯矩平面X-Z的法线
    [~,Comp_y,Comp_z] = line.getLocalCoordSystemComponent(normal_moment);% 获得法线向单元坐标系y和z轴的投影
    I = zeros(1,length(num_elem));
    M_i = zeros(1,length(num_elem));
    M_j = zeros(1,length(num_elem));
    for i=1:length(line)
        num_elem_line = Map_MatlabLine2AnsysElem(line(i).Num);
        for j = 1:length(num_elem_line)
            num_elem_line_j = num_elem_line(j);
            index_elem_j = num_elem == num_elem_line_j;
            Iyy_j = Iyy(index_elem_j);
            Izz_j = Izz(index_elem_j);
            Myi_j = Myi(index_elem_j);
            Mzi_j = Mzi(index_elem_j);
            Myj_j = Myj(index_elem_j);
            Mzj_j = Mzj(index_elem_j);

            I(index_elem_j) = Iyy_j*Comp_y(i) + Izz_j*Comp_z(i);
            M_i(index_elem_j) = Myi_j*Comp_y(i) + Mzi_j*Comp_z(i);
            M_j(index_elem_j) = Myj_j*Comp_y(i) + Mzj_j*Comp_z(i);
        end
    end
    % 去除I==0的数据
    index_I_nonzero = abs(I)>1e-5; % I不为0的index。I为0一般是单元朝向正好是全局坐标系的Y方向
    L = L(index_I_nonzero)';
    E = E(index_I_nonzero)';
    I = I(index_I_nonzero);
    M_i = M_i(index_I_nonzero);
    M_j = M_j(index_I_nonzero);
end