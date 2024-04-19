function addToSpan(obj,SpanType,num_Span,structureobj)
    arguments
        obj
        SpanType {mustBeMember(SpanType,{'MainSpan','SideSpan'})}
        num_Span (1,1) {mustBeNumeric}
        structureobj {mustBeA(structureobj,'Structure')}
    end
    switch SpanType
        case 'MainSpan'
            if isempty(obj.StructureCell_MainSpan{1,num_Span})
                obj.StructureCell_MainSpan{1,num_Span} = {structureobj};
            else
                obj.StructureCell_MainSpan{1,num_Span} = [obj.StructureCell_MainSpan{1,num_Span},{structureobj}];
            end
        case 'SideSpan'
            if isempty(obj.StructureCell_SideSpan{1,num_Span})
                obj.StructureCell_SideSpan{1,num_Span} = {structureobj};
            else
                obj.StructureCell_SideSpan{1,num_Span} = [obj.StructureCell_SideSpan{1,num_Span},{structureobj}];
            end
    end
end