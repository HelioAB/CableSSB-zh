function new_bridge = clone(obj)
    new_bridge = obj.empty;
    new_bridge(1).Params = struct;
    metaobj_from = metaclass(obj);
    props_from = {metaobj_from.PropertyList.Name};
    for i=1:length(props_from)
        new_bridge.(props_from{i}) = obj.(props_from{i});
    end
end