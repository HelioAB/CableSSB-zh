function addLoad(obj,load,options)
    arguments
        obj
        load
        options.Name {mustBeText} = ''
    end
    load.record;
    obj.addToList('Load',load);
    load_count = length(obj.LoadList);
    if isempty(options.Name)&&isempty(load.Name)
        load.edit('Name',['Load','_',num2str(load_count)]); % StructureName的默认值：先把StructureObj放进StructureList，再计数
    elseif ~isempty(load.Name)
    else
        load.edit('Name',char(options.Name));
    end
end