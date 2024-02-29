function [searched_structure,index,index_inner] = findStructureByInfo(obj,Info)
    % 在Bridge对象中，寻找所有与该Material、ElementType、Section有关的Structure对象
    % 确定搜寻范围
    if isa(Info,'ElementType')
        searching_list = obj.ElementTypeList;
    elseif isa(Info,'Material')
        searching_list = obj.MaterialList;
    elseif isa(Info,'Section')
        searching_list = obj.SectionList;
    elseif isa(Info,'Structure')
        searching_list = obj.StructureList;
    end

    % 确定待搜寻Info所在的index
    index = false(1,length(searching_list));
    index_inner = {}; % 例如如果Bridge.SectionList{i}不是一个对象，而是对象数组，就需要用到index_inner,来表示在Bridge.SectionList{i}内部的何处
    for i = 1:length(searching_list)
        searching_list_i = searching_list{i};
        index_j = searching_list_i==Info;
        if any(index_j)
            index(i) = true;
            index_inner{end+1} = index_j;
        end
    end
    searched_structure = obj.StructureList(index);
end