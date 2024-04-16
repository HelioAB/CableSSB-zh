function rigid_beam = buildRigidBeam(obj,IPoint,JPoint,IStructure,JStructure,section,material,element_type,division_num,options)
    arguments
        obj
        IPoint
        JPoint
        IStructure
        JStructure
        section = Section('RigidBeam')
        material = Material('RigidBeam')
        element_type = Beam188
        division_num = 1
        options.Name {mustBeText} = ''
    end
    rigid_beam = RigidBeam(IPoint,JPoint,section,material,'IStructure',IStructure,'JStructure',JStructure);
    rigid_beam.ElementType = element_type;
    rigid_beam.ElementDivisionNum = division_num;
    rigid_beam.record;
    section.unique.record;
    material.record;
    element_type.record;

    obj.updateList('Structure',rigid_beam,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(rigid_beam,options.Name)
end