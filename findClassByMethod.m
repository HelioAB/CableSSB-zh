function exist_method_class = findClassByMethod(MainPath,method_name)
    % 寻找文件夹下的所有.m文件和class
%     MainPath = genpath('.\');
    allpath = strsplit(MainPath,';');
    s = what(allpath{1});
    name = fieldnames(s);
    for i=2:length(allpath)
        s_i = what(allpath{i});
        for j=1:length(name)
            cell_0 = s.(name{j});
            cell_1 = s_i.(name{j});
            if ~isempty(cell_1)
                cell_0(end+1:end+length(cell_1)) = cell_1;
            end
            s.(name{j}) = cell_0;
        end
    end
    class_names = s.classes;% 文件夹下的所有class的名字
    
    % 寻找所有class的outputToAnsys成员方法
    exist_method_class = {};
    for i=1:length(class_names)
        class_name = class_names{i};
        method_names = methods(class_name);
        index_outputToAnsys = strcmpi(method_names,method_name);
        if any(index_outputToAnsys)
            exist_method_class(1,end+1) = {class_name};
        end
    end
end