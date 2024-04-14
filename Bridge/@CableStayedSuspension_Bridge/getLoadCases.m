function LoadCase = getLoadCases(obj,num_LoadCase,value_LoadCase)
    arguments
        obj
        num_LoadCase (1,1) {mustBeInteger,mustBeInRange(num_LoadCase,1,5)}
        value_LoadCase (1,1) {mustBeNumeric}
    end
    girders = obj.findStructureByClass('Girder');
    girder_mainspan = girders{1};
    girder_sidespan_1 = girders{2};
    girder_sidespan_2 = girders{3};

    % 5种荷载工况
    %       主跨    边跨1   边跨2
    % 工况1：满跨    满跨    满跨
    % 工况2：满跨    无      无
    % 工况3：半跨(1) 满跨    无
    % 工况4：半跨(2) 满跨    无
    % 工况5：无      满跨    满跨
    switch num_LoadCase
        case 1
            lines_Loaded_1 = girder_sidespan_1.findLineByCenterCoord('X','ascend');
            lines_Loaded_2 = girder_mainspan.findLineByCenterCoord('X','ascend');
            lines_Loaded_3 = girder_sidespan_2.findLineByCenterCoord('X','ascend');
            LoadCase = UniformLoad([lines_Loaded_1,lines_Loaded_2,lines_Loaded_3],'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况1';
        case 2
            lines_Loaded_1 = girder_mainspan.findLineByCenterCoord('X','ascend');
            LoadCase = UniformLoad(lines_Loaded_1,'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况2';
        case 3
            lines_Loaded_1 = girder_sidespan_1.findLineByCenterCoord('X','ascend');
            lines_temp = girder_mainspan.findLineByCenterCoord('X','ascend');
            index_halfspan = ceil(length(lines_temp)/2);
            lines_Loaded_2 = lines_temp(1:index_halfspan);
            LoadCase = UniformLoad([lines_Loaded_1,lines_Loaded_2],'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况3';
        case 4
            lines_Loaded_1 = girder_sidespan_1.findLineByCenterCoord('X','ascend');
            lines_temp = girder_mainspan.findLineByCenterCoord('X','ascend');
            index_halfspan = ceil(length(lines_temp)/2);
            lines_Loaded_2 = lines_temp(index_halfspan:end);
            LoadCase = UniformLoad([lines_Loaded_1,lines_Loaded_2],'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况4';
        case 5
            lines_Loaded_1 = girder_sidespan_1.findLineByCenterCoord('X','ascend');
            lines_Loaded_2 = girder_sidespan_2.findLineByCenterCoord('X','ascend');
            LoadCase = UniformLoad([lines_Loaded_1,lines_Loaded_2],'Z',-abs(value_LoadCase));
            LoadCase.Name = '工况5';
    end
end