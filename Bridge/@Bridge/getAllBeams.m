function elems_beam = getAllBeams(obj)
    structures = obj.StructureList;
    % 试探是否已经存储了Elements数据
    for i=1:length(structures)
        structure = structures{i};
        if isempty(structure.Element)
            error('在Bridge.StructureList的第%d个Structure对象中，还不存在Element，无法进行getAllBeams')
        end
    end
    % 提取所有为Beam
    elems_beam = [];
    for i=1:length(structures)
        structure = structures{i};
        if contains(structure.ElementType.Name,'Beam','IgnoreCase',true)
            elems_beam = [elems_beam,structure.Element];
        end
    end
end