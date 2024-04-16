function rigid_beam = buildRigidBeamByOffset(obj,FromPoint,FromStructure,Offset,section,material,element_type,division_num,options)
    arguments
        obj
        FromPoint
        FromStructure
        Offset
        section = Section('RigidBeam',RectangleSection(5,5))
        material = Material('RigidBeam',MaterialData_RigidBeam)
        element_type = Beam188
        division_num = 1
        options.Name {mustBeText} = ''
    end
    rigidbeam_point = FromPoint.clone();
    rigidbeam_point.translate(Offset);
    rigid_beam = RigidBeam(FromPoint,rigidbeam_point,section,material,'IStructure',FromStructure);
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