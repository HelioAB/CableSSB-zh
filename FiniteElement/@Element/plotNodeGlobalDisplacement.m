function [fig,ax] = plotNodeGlobalDisplacement(obj,Nodes_matrix,Displacement_matrix,type_displacement,options)
    % Nodes、Displacement 由 obj.getNodeGlobalDisplacement()提供
    arguments
        obj
        Nodes_matrix
        Displacement_matrix
        type_displacement {mustBeMember(type_displacement,{'Ux','Uy','Uz'})}
        options.ParametersValue (1,:) {mustBeNumeric} = []
        options.ParametersName {mustBeText} = ''
        options.Pattern {mustBeMember(options.Pattern,{'bar','plot3'})} = 'plot3'
        options.Scale = 1
        options.Figure = figure
        options.Axis = axes
        options.ForceName = ''
        options.ColorMap = 'jet'
        options.Title = ''
    end
    fig = options.Figure;
    ax = options.Axis;
    figure(fig)
    hold(ax,'on')
    sz = size(Nodes_matrix);
    %
    if isempty(options.ParametersValue)
        cell_legend = {'<Value>'};
    else
        cell_legend = cell(1,sz(1));
        for i=1:sz(1)
            cell_legend{i} = num2str(options.ParametersValue(i),'%.4f');
        end
    end
    %
    if ~isempty(options.ParametersValue) && length(options.ParametersValue) >= 2
        interpolated_cmap = interpolateColor(options.ParametersValue,options.ColorMap);
    else
        interpolated_cmap = [1,0,0];
    end
    %
    max_Displacement = max(Displacement_matrix,[],'all');
    min_Displacement = min(Displacement_matrix,[],'all');
    max_X_Nodes = max([Nodes_matrix.X],[],'all');
    min_X_Nodes = min([Nodes_matrix.X],[],'all');
    max_Y_Nodes = max([Nodes_matrix.Y],[],'all');
    min_Y_Nodes = min([Nodes_matrix.Y],[],'all');
    max_Z_Nodes = max([Nodes_matrix.Z],[],'all');
    min_Z_Nodes = min([Nodes_matrix.Z],[],'all');
    %
    for row = 1:sz(1)
        Nodes = Nodes_matrix(row,:);
        Displacement = Displacement_matrix(row,:);
        color = interpolated_cmap(row,:);
        switch options.Pattern
            case 'bar'
                error('暂不支持使用bar来作图')
            case 'plot3'
                len = length(Displacement);
                PostionX = zeros(1,len);
                PostionY = zeros(1,len);
                PostionZ = zeros(1,len);
                % if strcmp(type_nodes,'Girder')
                %     PostionX = [Nodes.X];
                %     PostionZ = [Nodes.Z] + options.Scale*Displacement;
                % elseif strcmp(type_nodes,'Tower')
                %     PostionX = [Nodes.X] + options.Scale*Displacement;
                %     PostionZ = [Nodes.Z];
                % end
                if strcmp(type_displacement,'Uz')
                    PostionX = [Nodes.X];
                    PostionZ = [Nodes.Z] + options.Scale*Displacement;
                    plot3(ax,PostionX,PostionY,PostionZ,'Color',color,'LineWidth',1)
                    ax.ZGrid = 'on';
                    ax.ZMinorTick = "on";
                    ax.XAxis.Label.String = '位置(m)';
                    ax.ZAxis.Label.String = options.ForceName;
                    ax.XLim = [min_X_Nodes,max_X_Nodes];
                    ax.ZLim = [min_Displacement,max_Displacement];
                elseif strcmp(type_displacement,'Ux')
                    PostionX = [Nodes.X] + options.Scale*Displacement;
                    PostionZ = [Nodes.Z];
                    plot3(ax,PostionX,PostionY,PostionZ,'Color',color,'LineWidth',1)
                    ax.XGrid = 'on';
                    ax.XMinorTick ="on";
                    ax.XAxis.Label.String = options.ForceName;
                    ax.ZAxis.Label.String = '塔高(m)';
                    ax.XLim = [min_Displacement,max_Displacement];
                    ax.ZLim = [min_Z_Nodes,max_Z_Nodes];
                end
                
        end
    end
    view([0,-1,0])
    ax.FontName = 'Times New Roman + SimSun';
    legend(ax,cell_legend,'Location','best');
    ax.Title.String = options.Title;
    ax.XLabel.String = '位置(m)';
    ax.TickDir = 'out';
end
function interpolated_cmap = interpolateColor(data,map)
    arguments
        data
        map = 'jet'
    end
    % 确定数据的最小值和最大值
    data_min = min(data);
    data_max = max(data);
    
    cmap = colormap(map);
    % 将数据归一化到[0, 1]的范围
    normalized_data = (data - data_min) / (data_max - data_min);
    
    % 使用interp1进行插值
    cmap_size = size(cmap, 1); % 获取colormap的大小
    interpolated_cmap = zeros(length(data),3); % 初始化颜色矩阵，大小与数据相同
    for i = 1:length(data)
        % 对于每个数据点，找到对应的颜色
        cmap_index = normalized_data(i) * (cmap_size - 1) + 1;
        interpolated_cmap(i,:) = interp1(1:cmap_size, cmap, cmap_index);
    end
end