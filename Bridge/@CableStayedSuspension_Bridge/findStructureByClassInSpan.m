function [structure_list,index] = findStructureByClassInSpan(obj,StructureClass,SideOrMain,numSpan)
    arguments
        obj
        StructureClass
        SideOrMain {mustBeMember(SideOrMain,{'Side','Main'})}
        numSpan (1,1) {mustBeInteger} = 1
    end
    switch SideOrMain
        case 'Side'
            structures = obj.StructureCell_SideSpan{numSpan};
        case 'Main'
            structures = obj.StructureCell_MainSpan{numSpan};
    end
    index = false(1,length(structures));
    for i=1:length(structures)
        structure = structures{i};
        if isa(structure,StructureClass)
            index(i) = true;
        end
    end
    structure_list = structures(index);
end