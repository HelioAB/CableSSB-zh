function [sorted_obj,index] = sortByReference(obj,reference,direction)
    % 输入参数reference必须和obj的size相同,且reference必须为数值向量
    arguments
        obj
        reference (1,:) {mustBeEqualSize(reference,obj),mustBeNumeric}
        direction {mustBeMember(direction,{'ascend','descend'})} = 'ascend' 
    end
    [~,index] = sort(reference,direction);
    sorted_obj = obj(index);
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end