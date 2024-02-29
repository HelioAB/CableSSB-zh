function tower = buildTowerByInput(obj,InputMethod,functionhandle_findRefPoint,Coord_MoveTo,section,material,element_type,division_num,options)
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
    tower = Tower();
    tower.Method_Creating = InputMethod;
    obj.InputMethod.InputTower = InputMethod;
    tower.create;

    RefPoint = functionhandle_findRefPoint(tower);% 使用函数句柄来寻找参考点
    tower.move(RefPoint,Coord_MoveTo);
    tower.Section = section;
    tower.Material = material;
    tower.ElementType = element_type;
    tower.ElementDivisionNum = division_num;
    tower.record;
    section.record;
    material.record;
    element_type.record;

    obj.updateList('Structure',tower,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    obj.editStructureName(tower,options.Name)
end