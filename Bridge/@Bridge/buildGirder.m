function girder = buildGirder(obj,CoordA,CoordB,L,section,material,element_type,division_num,options)
    arguments
        obj
        CoordA
        CoordB
        L
        section
        material
        element_type = Beam188
        division_num = 5
        options.Name {mustBeText} = ''
    end
    girder = Girder(CoordA,CoordB,L,section,material);
    girder.ElementType = element_type;
    girder.ElementDivisionNum = division_num;
    girder.record;
    section.record;
    material.record;
    element_type.record;

    obj.updateList('Structure',girder,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(girder,options.Name)
end