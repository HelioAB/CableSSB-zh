function [fig,ax] = plotStructure(obj,fig,ax,options)
    arguments
        obj
        fig = figure
        ax = axes
        options.ifPlotPoints = true
    end
    structures = obj.StructureList;
    len = length(structures);
    if len~=0
        lines = [];
        points = [];
        for i=1:len
            lines = [lines,structures{i}.Line];
            lines = lines.unique();
            points = [points,structures{i}.Point];
            points = points.unique();
        end
        figure(fig) % 将options.Figure设置为当前图窗
        hold(ax,'on')
        if options.ifPlotPoints
            points.plot('Figure',fig,'Axis',ax);
        end
        lines.plot('Figure',fig,'Axis',ax);
    end
end