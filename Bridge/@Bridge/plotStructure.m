function [fig,ax] = plotStructure(obj,fig,ax)
    arguments
        obj
        fig = figure
        ax = axes
    end
    len = length(obj.StructureList);
    if len~=0
        lines = [];
        points = [];
        for i=1:len
            lines = [lines,obj.StructureList{i}.Line];
            lines = lines.unique();
            points = [points,obj.StructureList{i}.Point];
            points = points.unique();
        end
        figure(fig) % 将options.Figure设置为当前图窗
        hold(ax,'on')
        points.plot('Figure',fig,'Axis',ax);
        lines.plot('Figure',fig,'Axis',ax);
    end
end