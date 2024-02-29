function record(obj)
    if isempty(obj)
        error('请record一个非空对象')
    end
    [uni_obj,~,~] = obj.unique();
    [rep_num,rep_obj,rep_index] = obj.findRepeat();
    if ~isempty(rep_num)
        assignin("base","RepNum",rep_num)
        assignin("base","RepObj",rep_obj)
        assignin("base","RepIndex",rep_index)
        warning('输入的对象数组中，存在重复编号的对象。重复编号、重复编号的对象和重复编号的索引分别储存在工作区的RepNum、RepObj和RepIndex三个变量中。')
    end
    [exi_num,exi_obj,exi_index,nonexi_obj] = uni_obj.findExisting();
    if ~isempty(exi_num)
        assignin("base","ExistNum",exi_num)
        assignin("base","ExistObj",exi_obj)
        assignin("base","ExistIndex",exi_index)
        assignin("base","NonExistIndex",nonexi_obj)
        warning('输入的对象数组中，有已记录过编号的对象。已记录编号、已记录编号的对象和已记录编号的索引分别储存在工作区的ExistNum、ExistObj和ExistIndex三个变量中。')
    end
    obj.Collection.addObj(nonexi_obj);
    for i=1:length(nonexi_obj)
        nonexi_obj(i).flag_recorded = true;
    end
end