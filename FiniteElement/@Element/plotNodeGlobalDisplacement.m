function [fig,ax] = plotNodeGlobalDisplacement(obj,Nodes,Displacement,type_nodes,options)
    % Nodes、Displacement 由 obj.getNodeGlobalDisplacement()提供
    arguments
        obj
        Nodes
        Displacement
        type_nodes {mustBeMember(type_nodes,{'Girder','Tower'})}
        options.Pattern {mustBeMember(options.Pattern,{'bar','plot3'})} = 'plot3'
        options.Scale = 100
        options.Figure = figure
        options.Axis = axes
    end
    fig = options.Figure;
    ax = options.Axis;
    figure(fig)
    switch options.Pattern
        case 'bar'
            error('暂不支持使用bar来作图')
        case 'plot3'
            len = length(Displacement);
            PostionX = zeros(1,len);
            PostionY = zeros(1,len);
            PostionZ = zeros(1,len);
            if strcmp(type_nodes,'Girder')
                PostionX = [Nodes.X];
                PostionZ = [Nodes.Z] + options.Scale*Displacement;
            elseif strcmp(type_nodes,'Tower')
                PostionX = [Nodes.X] + options.Scale*Displacement;
                PostionZ = [Nodes.Z];
            end
            plot3(ax,PostionX,PostionY,PostionZ,'Color','b','LineWidth',1)
    end
end