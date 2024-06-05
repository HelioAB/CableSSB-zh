function [fig,ax] = plotBackgroundBridge(obj,constraints,couplings)
    arguments
        obj
        constraints = []
        couplings = []
    end
    fig = figure;
    ax = axes;
    [fig,ax] = obj.plot("Figure",fig,'Axis',ax);
    axis equal;
    hold(ax,'on');
    if ~isempty(constraints)
        for i=1:length(constraints)
            constraints(i).plot('Figure',fig,'Axis',ax);
        end
    end
    if ~isempty(couplings)
        for i=1:length(couplings)
            couplings(i).plot('Figure',fig,'Axis',ax);
        end
    end
    view([0,-1,0])
end