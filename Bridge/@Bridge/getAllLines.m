function lines = getAllLines(obj)
    structures = obj.StructureList;
    lines = [];
    % 试探是否已经存储了Elements数据
    for i=1:length(structures)
        structure = structures{i};
        lines = [lines,structure.Line];
    end
    lines = lines.unique();
end