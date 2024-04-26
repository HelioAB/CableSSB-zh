function tf = isempty(obj)
    name_properties = {'MaterialList','SectionList','ElementTypeList',...
                       'ElementDivisionList','StructureList','CouplingList',...
                       'ConstraintList','LoadList','OutputMethod'}; 
    index = false(1,length(name_properties));
    for i=1:length(name_properties)
        name_property = name_properties{i};
        index(i) = isempty(obj.(name_property));
    end
    tf = all(index);
end