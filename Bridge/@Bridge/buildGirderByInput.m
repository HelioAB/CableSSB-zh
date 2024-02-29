function girder = buildGirderByInput(obj,InputMethod,functionhandle_findRefPoint,Coord_MoveTo,section,material,element_type,division_num,options)
    arguments
        obj
        InputMethod {mustBeA(InputMethod,'InputFrom')}
        functionhandle_findRefPoint {mustBeA(functionhandle_findRefPoint,'function_handle')} % 这是一个寻找参考点的函数句柄，该函数句柄以girder为未知量
        Coord_MoveTo
        section
        material
        element_type = Beam188
        division_num = 5
        options.Name {mustBeText} = ''
    end
    girder = Girder();
    girder.Method_Creating = InputMethod;
    girder.create;
    
    RefPoint = functionhandle_findRefPoint(girder);% 使用函数句柄来寻找参考点
    girder.move(RefPoint,Coord_MoveTo);
    girder.Section = section;
    girder.Material = material;
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