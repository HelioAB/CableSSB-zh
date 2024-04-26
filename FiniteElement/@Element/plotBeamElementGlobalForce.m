function [fig,ax] = plotBeamElementGlobalForce(obj,ANodes,BNodes,InternalForce_A,InternalForce_B,type_elems,options)
    % 输入参数ANodes、BNodes、InternalForce_A、InternalForce_B 由obj.getBeamElementGlobalForce()提供
    arguments
        obj
        ANodes
        BNodes
        InternalForce_A
        InternalForce_B
        type_elems {mustBeMember(type_elems,{'Girder','Tower'})}
        options.Pattern {mustBeMember(options.Pattern,{'bar','plot3'})} = 'plot3'
        options.Scale = 1e-8
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
            len = length(InternalForce_A);
            PostionX = zeros(1,2*len);
            PostionY = zeros(1,2*len);
            PostionZ = zeros(1,2*len);
            if strcmp(type_elems,'Girder')
                PostionX(1:2:end) = [ANodes.X];
                PostionX(2:2:end) = [BNodes.X];
                PostionZ(1:2:end) = [ANodes.Z] + options.Scale*InternalForce_A;
                PostionZ(2:2:end) = [BNodes.Z] + options.Scale*InternalForce_B;
            elseif strcmp(type_elems,'Tower')
                PostionX(1:2:end) = [ANodes.X] + options.Scale*InternalForce_A;
                PostionX(2:2:end) = [BNodes.X] + options.Scale*InternalForce_B;
                PostionZ(1:2:end) = [ANodes.Z];
                PostionZ(2:2:end) = [BNodes.Z];
            end
            plot3(ax,PostionX,PostionY,PostionZ,'Color','r','LineWidth',1)
    end
end