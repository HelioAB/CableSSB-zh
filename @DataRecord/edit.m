function edit(obj,PropertyName,ChangeTo)
    % 为什么需要edit成员方法而不是直接点操作？
    % 因为：
    %   1.对于一个对象数组，不能直接使用点操作修改整个对象数组，但是edit成员方法可以
    %   2.edit成员方法会进行很多参数验证，因此更安全
    arguments
        obj (1,:)
        PropertyName (1,:) {mustBeText}
        ChangeTo (1,:)
        % ChangeTo的多有可能情况, 以及如何衡量它们的个数：
        % 1. Numeric: count=length(ChangeTo)
        % 2. Text: 
        %       a. char: count≠length(ChangeTo), 需要先转换成string类型
        %       b. string: count=length(ChangeTo)
        %       c. cell: count=length(ChangeTo)
        % 3. User Defined Object: count=length(ChangeTo)
    end
    if ~isempty(obj)
        for i=1:length(obj)
            if isempty(ChangeTo)
                obj(i).editObj(PropertyName,[]);
            elseif isa(ChangeTo,'char')
                obj(i).editObj(PropertyName,ChangeTo);
            elseif length(ChangeTo)==1
                obj(i).editObj(PropertyName,ChangeTo);
            elseif isa(ChangeTo,'cell')
                obj(i).editObj(PropertyName,ChangeTo{i});
            else
                obj(i).editObj(PropertyName,ChangeTo(i));
            end
        end
    else
        error('指定编辑对象为空，请重试。')
    end
end