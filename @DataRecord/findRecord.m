function recorded = findRecord(obj)
    recorded = obj.empty;
    for i=1:length(obj)
        if obj(i).flag_recorded
            recorded(1,end+1) = obj(i);
        end
    end
end