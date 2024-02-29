function plotLoad(obj,fig,ax,scale)
    arguments
        obj
        fig
        ax
        scale = 1
    end
    len = length(obj.LoadList);
    if len ~= 0
        for i=1:len
            obj.LoadList{i}.plot('Scale',scale,'Figure',fig,'Axis',ax);
        end
    end
end