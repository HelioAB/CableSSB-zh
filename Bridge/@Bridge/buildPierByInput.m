function pier = buildPierByInput(obj,InputMethod,functionhandle_findRefPoint,Coord_MoveTo,section,material,element_type,division_num,options)
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
    pier = Pier();
    pier.Method_Creating = InputMethod;
    obj.InputMethod.InputPier = InputMethod;
    pier.create;

    RefPoint = functionhandle_findRefPoint(pier);% 使用函数句柄来寻找参考点
    pier.move(RefPoint,Coord_MoveTo);
    pier.Section = section;
    pier.Material = material;
    pier.ElementType = element_type;
    pier.ElementDivisionNum = division_num;
    pier.record;
    section.unique.record;
    material.record;
    element_type.record;

    obj.updateList('Structure',pier,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(pier,options.Name)
end