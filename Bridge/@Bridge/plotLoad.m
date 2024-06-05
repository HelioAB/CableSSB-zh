function plotLoad(obj,fig,ax,options)
    arguments
        obj
        fig
        ax
        options.Scale = 1
        options.LineWidth = 1
        options.Offset = [0,0,0]
        options.HidedLoadName = {}
    end
    len = length(obj.LoadList);
    if len ~= 0
        for i=1:len
            load = obj.LoadList{i};
            if any(strcmp(load.Name,options.HidedLoadName))
            else
                load.plot('Scale',options.Scale, ...
                                     'Figure',fig, ...
                                     'Axis',ax, ...
                                     'LineWidth',options.LineWidth,...
                                     'Offset',options.Offset);
            end
        end
    end
end