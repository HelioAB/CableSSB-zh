function [nodes,elements] = getAllNodesAndAllElements(obj)
    bridgeobj = obj.OutputObj;
    Map_MatlabLine2AnsysElement = bridgeobj.Params.Map_MatlabLine2AnsysElem;

    % 输出所有Nodes和Elements
    structures = bridgeobj.StructureList;
    num_all_elems = [];
    num_structure_elems = cell(1,length(structures));
    for i=1:length(structures)
        structure = structures{i};
        lines = structure.Line;
        num_lines = [lines.Num];
        num_elems = values(Map_MatlabLine2AnsysElement,num2cell(num_lines));
        num_all_elems = [num_all_elems,cell2mat(num_elems)];
        num_structure_elems{i} = cell2mat(num_elems);
    end
    num_all_elems = unique(num_all_elems);
    [nodes,index_inodes,index_jnodes] = obj.getNodeByNumElements(num_all_elems);
    inodes = nodes(index_inodes);
    jnodes = nodes(index_jnodes);
    elements = Element(num_all_elems,inodes,jnodes);
    % 为每个structure赋予Element属性和Node属性
    for i=1:length(structures)
        structure = structures{i};
        num_elems = num_structure_elems{i};
        elems_structure = elements.findObjByNum(num_elems);
        structure.Element = elems_structure;
    end
end