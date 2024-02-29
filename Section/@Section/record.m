function record(obj)
    uni_sec = obj.unique;
    for i=1:length(uni_sec)
        sec = uni_sec(i);
        if ~sec.flag_recorded
            max_num = Section.MaxNum;
            sec.Num = max_num+1;
            sec.Collection.addObj(sec);
            sec.flag_recorded = true;
        end
    end
end