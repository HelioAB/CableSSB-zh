function span = getSpan(obj,SideOrMain,numSpan)
    arguments
        obj
        SideOrMain {mustBeMember(SideOrMain,{'Side','Main'})}
        numSpan (1,1) {mustBeInteger} = 1
    end
    switch SideOrMain
        case 'Side'
            structures = obj.StructureCell_SideSpan{numSpan};
        case 'Main'
            structures = obj.StructureCell_MainSpan{numSpan};
    end
    span = 0;
    for i=1:length(structures)
        structure = structures{i};
        if isa(structure,'Girder')
            span = span + structure.Span();
        end
    end
end