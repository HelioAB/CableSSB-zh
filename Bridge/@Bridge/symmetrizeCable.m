function symm_cable = symmetrizeCable(obj,cable,symmetry_point,symmetry_vector,options)
    arguments
        obj
        cable
        symmetry_point = [0,0,0]
        symmetry_vector = [0,1,0]
        options.Name {mustBeText} = ''
    end
    symm_cable = cable.clone();
    symm_cable.record;
    symm_cable.symmetrize(symmetry_point,symmetry_vector);
    
    % 添加原Cable和复制后的Cable之间的关系，这里是对称关系
    cable.RelatedToStructure.RelatedStructure = symm_cable;
    cable.RelatedToStructure.Relation = 'Symmetrizing To';
    cable.RelatedToStructure.RelationData = struct('SymmetricPoint',symmetry_point,'PlaneOfSymmetry',symmetry_vector);

    symm_cable.RelatedToStructure.RelatedStructure = cable;
    symm_cable.RelatedToStructure.Relation = 'Symmetrized From';
    symm_cable.RelatedToStructure.RelationData = struct('SymmetricPoint',symmetry_point,'PlaneOfSymmetry',symmetry_vector);

    obj.updateList('Structure',symm_cable,'Section',symm_cable.Section.unique, ...
                    'Material',symm_cable.Material,'ElementType',symm_cable.ElementType,'ElementDivision',symm_cable.ElementDivisionNum)
    obj.editStructureName(symm_cable,options.Name);

    symm_cable.addConnectPoint(symm_cable.ForcePoint);
end