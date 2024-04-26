function [sorted_nodes,Displacement] = getNodeGlobalDisplacement(obj,type_elems,type_displacement)
    arguments
        obj
        type_elems {mustBeMember(type_elems,{'Girder','Tower'})}
        type_displacement {mustBeMember(type_displacement,{'Ux','Uy','Uz'})}
    end
    % 该函数是用来输出内力值，内力值在图中的大小需要依赖该函数
    if strcmp(type_elems,'Girder')
        direction_sort = 'X';        
    elseif strcmp(type_elems,'Tower')
        direction_sort = 'Z';
    end
    inodes = [obj.INode];
    jnodes = [obj.JNode];
    nodes = [inodes,jnodes];
    uni_nodes = nodes.unique();
    sorted_nodes = uni_nodes.sort(direction_sort);
    GlobalDisplacement = [sorted_nodes.Displacement_GlobalCoord];
    switch type_displacement
        case 'Ux'
            Displacement = GlobalDisplacement(1,:);
        case 'Uy'
            Displacement = GlobalDisplacement(2,:);
        case 'Uz'
            Displacement = GlobalDisplacement(3,:);
    end
end