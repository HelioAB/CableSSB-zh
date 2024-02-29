function edit(obj,PropertyName,ChangeTo)
    arguments
        obj
        PropertyName {mustBeMember(PropertyName,{'Num','Name'})}
        ChangeTo
    end
    if strcmp(PropertyName,'Num')
        warning_text = ['以下编号的Material未被记录：',num2str()];
    elseif strcmp(PropertyName,'Name')
        warning_text = ['以下名字的Material未被记录：'];
    end
    edit@DataRecord(obj,PropertyName,ChangeTo,warning_text)
end