function [cable,Output] = buildMainSpanCable(obj,CoordA,CoordB,L,index_hanger,P_h_x,P_h_y,P_h_z,z_Om,section,material,element_type,division_num,Algo_ShapeFinding,options)
    arguments
        obj
        CoordA
        CoordB
        L
        index_hanger
        P_h_x
        P_h_y
        P_h_z
        z_Om
        section
        material
        element_type = Link10
        division_num = 1
        Algo_ShapeFinding = Catenary3D_MainSpan
        options.Name {mustBeText} = '' % 所有buildStructure赋予Name的逻辑：
        % 如果options.Name为空，就赋予obj.Name以模板名称：ClassName_01, ClassName_02.
        % 如果options.Name非空，就赋予obj.Name以otions.Name：Name01, Name02.
    end
    % 新建主缆cable1(Main Span Cable 1)
    cable = Cable(CoordA,CoordB,L,section,material);

    cable.ElementType = element_type;
    cable.ElementDivisionNum = division_num;
    cable.record;
    section.record;
    material.record;
    element_type.record;
    %
    obj.updateList('Structure',cable,'Section',section.unique,'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(cable,options.Name)
    % 设置外力
    [P_x,P_y,P_z] = cable.P(index_hanger,P_h_x,P_h_y,P_h_z);
    cable.addConnectPoint(cable.ForcePoint);
    % 设置其他需要的参数
    cable.Params.z_Om = z_Om;
    % 设置找形方法
    cable.Algo_ShapeFinding = Algo_ShapeFinding;
    % 找形
    Output = cable.findShape(P_x,P_y,P_z);
    
end