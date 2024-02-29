function unrecorded = findUnrecord(obj)
    unrecorded = obj.empty;
    for i=1:length(obj)
        if ~obj(i).flag_recorded
            unrecorded(1,end+1) = obj(i);
        end
    end
end