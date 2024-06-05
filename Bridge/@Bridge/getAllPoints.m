function points = getAllPoints(obj)
    structures = obj.StructureList;
    points = [];
    % 试探是否已经存储了Elements数据
    for i=1:length(structures)
        structure = structures{i};
        points = [points,structure.Point];
    end
    points = points.unique();
end