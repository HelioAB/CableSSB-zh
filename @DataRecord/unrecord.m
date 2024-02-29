function unrecord(obj)
    recorded = obj.checkRecordState();
    if ~isempty(recorded) && ~isempty(obj.Collection)
        for i=1:length(recorded)
            obj.Collection.deleteObj(recorded(i));
        end
    end
end