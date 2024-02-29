function [fig,ax] = plotStructure(obj,fig,ax)
    arguments
        obj
        fig = figure
        ax = axes
    end
    len = length(obj.StructureList);
    if len~=0
        for i=1:len
            obj.StructureList{i}.plot('Figure',fig,'Axis',ax);
        end
    end
end