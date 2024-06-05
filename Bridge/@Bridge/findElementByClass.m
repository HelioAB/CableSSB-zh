function elements = findElementByClass(obj,StructureClass)
    arguments
        obj
        StructureClass {mustBeText} = ''
    end
    index = false(1,length(obj.StructureList));
    elements = [];
    if ~isempty(StructureClass)
        for i=1:length(obj.StructureList)
            structure = obj.StructureList{i};
            if strcmpi(class(structure),StructureClass)
                if ~isempty(structure.Element)
                    elements = [elements,structure.Element];
                end
            end
        end
    end
    elements = elements.unique();
end