function removeLoadCase(obj,num_LoadCase)
    arguments
        obj
        num_LoadCase (1,1) {mustBeInteger,mustBeInRange(num_LoadCase,1,5)}
    end
    loads = obj.LoadList;
    index = false(1,length(loads));
    for i=1:length(loads)
        load = loads{i};
        if strcmp(load.Name,sprintf('工况%d',num_LoadCase))
            index(i) = true;
        end
    end
    obj.LoadList(index) = [];
end

