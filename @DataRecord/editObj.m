function editObj(obj,PropertyName,ChangeTo)
    arguments
        obj (1,1)
        PropertyName (1,:) {mustBeText}
        ChangeTo
    end
    if isempty(ChangeTo)
        obj.(PropertyName) = [];
    elseif isa(ChangeTo,class(obj.(PropertyName)))
        obj.(PropertyName) = ChangeTo;
    else
        error('请保持修改之后的值和原来属于相同的类。')
    end
end