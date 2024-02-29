function BendingStraintEnergy = getBendingStrainEnergy(obj)
    len = length(obj);
    BendingStraintEnergy = zeros(1,len);
    L = obj.ElementLength;
    normal_moment = [0,1,0];% 弯矩平面X-Z的法线
    [~,Comp_y,Comp_z] = obj.getLocalCoordSystemComponent(normal_moment);% 获得法线向单元坐标系y和z轴的投影
    for i=1:len
        element = obj(i);
        section_data = element.Section.SectionData;
        Iyy = section_data.Iyy; % 如果这个计算开销不显著，就不需要修改SectionData中的定义
        Izz = section_data.Izz;
        E = element.Material.MaterialData.E;
        force_vector = element.AnsysForceResult; % 这个开销非常显著，其中Element.Displacement_GlobalCoord的get函数非常显著
        Myi = force_vector(5);
        Mzi = force_vector(6);
        Myj = force_vector(11);
        Mzj = force_vector(12);
        I = Iyy*Comp_y(i) + Izz*Comp_z(i);
        M_i = Myi*Comp_y(i) + Mzi*Comp_z(i);
        M_j = Myj*Comp_y(i) + Mzj*Comp_z(i);
        if I~=0
            BendingStraintEnergy(i) = L(i)/(6*E*I)*(M_i^2+M_i*M_j+M_j^2);
        end
    end
end