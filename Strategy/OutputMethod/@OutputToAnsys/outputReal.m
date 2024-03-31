function output_str = outputReal(obj,fileName)
    arguments
        obj
        fileName = 'defReal.mac'
    end
    element_type_list = obj.OutputObj.ElementTypeList;
    index_output_link_real = false(1,length(element_type_list));
    index_output_beam4_real = false(1,length(element_type_list));
    for i=1:length(element_type_list)
        element_type_name = element_type_list{i}.Name;
        if strncmpi(element_type_name,'Link',4) % 区分处Link单元还是Beam4单元
            index_output_link_real(i) = true;
        elseif strcmpi(element_type_name,'beam4')
            index_output_beam4_real(i) = true;
        end
    end
    link_structure_list = obj.OutputObj.StructureList(index_output_link_real);
    beam4_structure_list = obj.OutputObj.StructureList(index_output_beam4_real);
    len_link = length(link_structure_list);
    len_beam4 = length(beam4_structure_list);


    % 输出的APDL字符串
    output_str = '';
    for i=1:len_link
        structure = link_structure_list{i};
        Line_list = structure.Line;
        Num = [Line_list.Num];
        A = structure.Section.Area;
        Init_strain = structure.Strain;
        
        % 输出注释
        output_str = [output_str,sprintf('! 结构名称名称: %s',structure.Name),newline];
        % 输出实常数
        output_str = [output_str,outputLinkReal(Num,A,Init_strain)];
        % 输出分隔行
        output_str = [output_str,'!------------------------- \n'];
        
    end
    for i=1:len_beam4
        structure = beam4_structure_list{i};
        Num = [structure.Line.Num];
        Sec_list = structure.Section;

        % 输出注释
        output_str = [output_str,sprintf('! 结构名称名称: %s',structure.Name),newline];
        % 输出实常数
        output_str = [output_str,outputBeam4Real(Num,Sec_list)];
        % 输出分隔行
        output_str = [output_str,'!------------------------- \n'];

    end
    % 输出到defMaterial.mac
    outputAPDL(obj,output_str,fileName,'w')
end
function output_str = outputLinkReal(Num_list,Area_list,Init_strain_list)
    % 1个LinkReal和1个Line对应
    len = length(Num_list);
    output_str = '';
    for j = 1:len
        output_str = [output_str,sprintf('r,%d,%.6e,%.6e \n',Num_list(j),Area_list(j),Init_strain_list(j))];
    end
end
function output_str = outputBeam4Real(Num_list,Sec_list)
    len = length(Num_list);
    % 输出apdl
    output_str = '';
    for i=1:len
        section_data = Sec_list(i).SectionData;
        if ~isa(section_data,'UserSection')
            error('暂时只支持输入截面数据为UserSection对象的Section对象数组作为beam4单元的实常数')
        end
        output_str = strcat(output_str,sprintf(['r,%d,%.6e,%.6e,%.6e,%.6e,%.6e ' ...
                                                '$ rmore,,%.6e \n'], ...
                                                Num_list(i),section_data(i).A,section_data(i).Izz,section_data(i).Iyy,section_data(i).TKz,section_data(i).TKy, ...
                                                section_data(i).Ixx));
        % r,Num_Real,Area,Izz,Iyy,Tkz,Tky,Theta
        % rmore,InitStrain,Ixx,ShearZ,ShearY,Spin,AddMass
    end
end
