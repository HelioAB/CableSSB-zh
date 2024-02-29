function [recorded,unrecorded] = checkRecordState(obj)
    unrecorded = obj.findUnrecord();
    recorded = obj.findRecord();
end