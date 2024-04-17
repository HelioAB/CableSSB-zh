function action(obj)
    structures = obj.StructureList;
    sheet_Coordination = [];
    sheet_LayerRange = {};
    sheet_LayerStructure = struct;
    count_start = 0;
    count_end = 0;
    for i=1:length(structures)
        structure = structures{i};
        lines = structure.Line;
        count_start = count_end + 1;
        count_end = count_end + length(lines);
        ipoints = [lines.IPoint];
        jpoints = [lines.JPoint];
        x_ipoints = [ipoints.X];
        y_ipoints = [ipoints.Y];
        z_ipoints = [ipoints.Z];
        x_jpoints = [jpoints.X];
        y_jpoints = [jpoints.Y];
        z_jpoints = [jpoints.Z];
        sheet_Coordination = [sheet_Coordination;...
                             x_ipoints',y_ipoints',z_ipoints',x_jpoints',y_jpoints',z_jpoints'];
        sheet_LayerRange = [sheet_LayerRange;...
                            {structure.Name,count_start,count_end}];
        if isfield(sheet_LayerStructure,class(structure))
            sheet_LayerStructure.(class(structure)) = [sheet_LayerStructure.(class(structure)),structure.Name];
        else
            sheet_LayerStructure.(class(structure)) = {structure.Name};
        end
    end
end