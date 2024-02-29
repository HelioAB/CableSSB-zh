function tf = isempty(obj)
    tf = true;
    metaobj = metaclass(obj);
    props = {metaobj.PropertyList.Name};
    for i=1:length(props)
        if ~isempty(obj.(props{i})) && ~strcmp(props{i},'MaterialType')
            tf = false;
        end
    end
end