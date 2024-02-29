function edit(obj,PropertyName,ChangeTo)
    arguments
        obj
        PropertyName {mustBeMember(PropertyName,{'Num','IPoint','JPoint'})}
        ChangeTo
    end
    if (any(size([obj.(PropertyName)])~=size(ChangeTo)))&&(length(ChangeTo)~=1)&&(~isempty(ChangeTo))
        error('待编辑值的原size和编辑后size不同！')
    end
    edit@DataRecord(obj,PropertyName,ChangeTo)
end