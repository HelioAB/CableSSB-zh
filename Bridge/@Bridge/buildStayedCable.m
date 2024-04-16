function stayed_cable = buildStayedCable(obj,IPoint,JPoint,IStructure,JStructure,section,material,element_type,division_num,options)
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
    stayed_cable = StayedCable(IPoint,JPoint,section,material,'IStructure',IStructure,'JStructure',JStructure);
    stayed_cable.ElementType = element_type;
    stayed_cable.ElementDivisionNum = division_num;
    stayed_cable.record;
    section.unique.record;
    material.record;
    element_type.record;
    
    obj.updateList('Structure',stayed_cable,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(stayed_cable,options.Name)
end