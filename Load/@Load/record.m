function record(obj)
    if ~obj.flag_recorded
        max_num = Load.MaxNum;
        obj.Num = max_num+1;
        obj.Collection.addObj(obj);
        obj.flag_recorded = true;
    end
end