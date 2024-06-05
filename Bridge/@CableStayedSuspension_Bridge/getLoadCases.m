function LoadCase = getLoadCases(obj,num_LoadCase,value_LoadCase)
    arguments
        obj
        num_LoadCase (1,1) {mustBeInteger,mustBeInRange(num_LoadCase,1,5)}
        value_LoadCase (1,1) {mustBeNumeric}
    end
    girders_mainspan = findStructureByClassInCell(obj.StructureCell_MainSpan{1},'Girder');
    girders_sidespan_1 = findStructureByClassInCell(obj.StructureCell_SideSpan{1},'Girder');
    girders_sidespan_2 = findStructureByClassInCell(obj.StructureCell_SideSpan{2},'Girder');

    % 5种荷载工况
    %       主跨    边跨1   边跨2
    % 工况1：满跨    满跨    满跨
    % 工况2：满跨    无      无
    % 工况3：半跨(1) 满跨    无
    % 工况4：半跨(2) 满跨    无
    % 工况5：无      满跨    满跨
    switch num_LoadCase
        case 1
            lines_Loaded = [];
            for i=1:length(girders_sidespan_1)
                girder = girders_sidespan_1(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            for i=1:length(girders_sidespan_2)
                girder = girders_sidespan_2(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            for i=1:length(girders_mainspan)
                girder = girders_mainspan(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            lines_Loaded = lines_Loaded.sortByCenterPoint('X');
            LoadCase = UniformLoad(lines_Loaded,'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况1';
        case 2
            lines_Loaded = [];
            for i=1:length(girders_mainspan)
                girder = girders_mainspan(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            lines_Loaded = lines_Loaded.sortByCenterPoint('X');
            LoadCase = UniformLoad(lines_Loaded,'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况2';
        case 3
            lines_Loaded = [];
            for i=1:length(girders_sidespan_1)
                girder = girders_sidespan_1(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            lines_temp = girders_mainspan.findLineByCenterCoord('X','ascend');
            index_halfspan = ceil(length(lines_temp)/2);
            lines_Loaded = [lines_Loaded,lines_temp(1:index_halfspan)];
            lines_Loaded = lines_Loaded.sortByCenterPoint('X');
            LoadCase = UniformLoad(lines_Loaded,'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况3';
        case 4
            lines_Loaded = [];
            for i=1:length(girders_sidespan_1)
                girder = girders_sidespan_1(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            lines_temp = girders_mainspan.findLineByCenterCoord('X','ascend');
            index_halfspan = ceil(length(lines_temp)/2);
            lines_Loaded = [lines_Loaded,lines_temp(index_halfspan:end)];
            lines_Loaded = lines_Loaded.sortByCenterPoint('X');
            LoadCase = UniformLoad(lines_Loaded,'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况4';
        case 5
            lines_Loaded = [];
            for i=1:length(girders_sidespan_1)
                girder = girders_sidespan_1(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            for i=1:length(girders_sidespan_2)
                girder = girders_sidespan_2(i);
                lines_Loaded = [lines_Loaded,girder.Line];
            end
            lines_Loaded = lines_Loaded.sortByCenterPoint('X');
            LoadCase = UniformLoad(lines_Loaded,'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况5';
    end
end
function structures = findStructureByClassInCell(StructureCell,class_name)
    structures = [];
    for i=1:length(StructureCell)
        structure = StructureCell{i};
        if isa(structure,class_name)
            structures = [structures,StructureCell{i}];
        end
    end
end