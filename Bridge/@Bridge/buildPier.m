function pier = buildPier(obj,CoordBottom,CoordTop,L,section,material,element_type,division_num,options)
    arguments
        obj
        CoordBottom
        CoordTop
        L
        section
        material
        element_type = Beam188
        division_num = 5
        options.Name {mustBeText} = ''
    end
    pier = Pier(CoordBottom,CoordTop,L,section,material);
    pier.ElementType = element_type;
    pier.ElementDivisionNum = division_num;
    pier.record;
    section.record;
    material.record;
    element_type.record;

    obj.updateList('Structure',pier,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(pier,options.Name)
end