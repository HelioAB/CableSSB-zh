function output_str = outputReal(obj,Num_list,Sec_list)
    len = length(Num_list); 
    % 输出字符串
    output_str = '';
    for i=1:len
        section_data = Sec_list(i).SectionData;
        if ~isa(section_data,'UserSection')
            error('暂时只支持输入截面数据为UserSection对象的Section对象数组')
        end
        output_str = strcat(output_str,sprintf(['r,%d,%.6e,%.6e,%.6e,%.6e,%.6e ' ...
                                                '$ rmore,,%.6e \n'], ...
                                                Num_list(i),section_data(i).A,section_data(i).Izz,section_data(i).Iyy,section_data(i).TKz,section_data(i).TKy, ...
                                                section_data(i).Ixx));
    end
   
end