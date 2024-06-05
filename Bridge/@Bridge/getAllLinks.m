function elems_link = getAllLinks(obj)
    structures = obj.StructureList;
    % 试探是否已经存储了Elements数据
    for i=1:length(structures)
        structure = structures{i};
        if isempty(structure.Element)
            error(sprintf('在Bridge.StructureList的第%d个Structure对象中，还不存在Element，无法进行getAllBeams',i))
        end
    end
    % 提取所有为Link
    elems_link = [];
    for i=1:length(structures)
        structure = structures{i};
        if contains(structure.ElementType.Name,'Link','IgnoreCase',true)
            elems_link = [elems_link,structure.Element];
        end
    end
end