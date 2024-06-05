function tf = isempty(obj)
    name_properties = {'MaterialList','SectionList','ElementTypeList',...
                       'ElementDivisionList','StructureList','CouplingList',...
                       'ConstraintList','LoadList','OutputMethod'}; 
    index = false(1,length(name_properties));
    PropertiesNames = {metaclass(obj).PropertyList.Name};
    
    for i=1:length(name_properties)
        if any(contains(PropertiesNames,name_properties{i}))
            value_property = obj.(name_properties{i});
            index(i) = isempty(value_property);
        end
    end
    tf = all(index);
end