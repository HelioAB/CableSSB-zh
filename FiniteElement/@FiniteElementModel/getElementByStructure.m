function ElementArray = getElementByStructure(obj,structure_list)
    len = length(structure_list);
    % 将输入的structure_list转换为cell，方便后续处理
    if (len==1) && (~isa(structure_list,'cell')) % 一个Structure对象，转换为cell
        StructureList = {structure_list};
    elseif (len>=2) && (~isa(structure_list,'cell')) % 多个Structure构成的对象数组，转换为cell
        StructureList = cell(1,len);
        for i=1:len
            StructureList{i} = structure_list(i);
        end
    else
        StructureList = structure_list;
    end
    % 计数element一共有多少个，提前分配好存储空间
    count_element = 0;
    for i=1:len
        structure = StructureList{i};
        division = structure.ElementDivisionNum;
        count_line = length(structure.Line);
        count_element = count_element+division*count_line;
    end
    ElementArray = Element.empty;
    ElementArray(1,count_element).Num = [];
    % 获取element
    position_element = 1;
    Line2Element = obj.Maps.Line2Element;
    Num2Element = obj.Maps.Element;
    for i=1:len
        structure = StructureList{i};
        division = structure.ElementDivisionNum;
        num_line = [structure.Line.Num];
        for j=1:length(num_line)
            num_element = Line2Element(num_line(j));
            for k=1:length(num_element)
                ElementArray(position_element) = Num2Element(num_element(k));
                position_element = position_element + 1;
            end
        end
    end
end