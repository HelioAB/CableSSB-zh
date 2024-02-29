function hanger = buildHanger(obj,IPoint,JPoint,IStructure,JStructure,section,material,element_type,division_num,options)
    arguments
        obj
        IPoint
        JPoint
        IStructure
        JStructure
        section
        material
        element_type = Link10
        division_num = 1
        options.Name {mustBeText} = ''
    end
    hanger = Hanger(IPoint,JPoint,section,material,'IStructure',IStructure,'JStructure',JStructure);
    hanger.ElementType = element_type;
    hanger.ElementDivisionNum = division_num;
    hanger.record;
    section.record;
    material.record;
    element_type.record;

    obj.updateList('Structure',hanger,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(hanger,options.Name)
end