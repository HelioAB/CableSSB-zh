function outputAPDL(obj,output_str,file_name,permission) 
    splited_str = split(file_name,'\');
    if strcmp(splited_str,file_name) % 如果输入的是不带文件路径的文件名
        file_path = [obj.WorkPath,'\',file_name];
    else % 如果输入的是带文件路径的文件名
        file_path = file_name;
    end
    % 需要注意的转义字符'%'、'\'
    fileID = fopen(file_path,permission);
    fprintf(fileID,output_str);
    fclose(fileID);
end
        