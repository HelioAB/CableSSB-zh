function nodes = getAllNodes(obj)
    structures = obj.StructureList;
    % 试探是否已经存储了Elements数据
    for i=1:length(structures)
        structure = structures{i};
        if isempty(structure.Element)
            error('在Bridge.StructureList的第%d个Structure对象中，还不存在Element，无法进行getAllBeams')
        end
    end
    % 提取所有的Nodes
    elems = [];
    for i=1:length(structures)
        structure = structures{i};
        elems = [elems,structure.Element];
    end
    inodes = [elems.INode];
    jnodes = [elems.JNode];
    knodes = [elems.KNode];
    knodes = knodes.unique();
    nodes = [inodes,jnodes,knodes];
    nodes = nodes.unique();    
end