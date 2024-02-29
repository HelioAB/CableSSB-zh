function [sorted_obj,index] = sort(obj,PropertyName,direction)
    % 重载Matlab内置的sort函数
    % 默认对Num属性进行排序
    % 'ascend' 表示升序（默认值），'descend' 表示降序。
    % obj == sorted_obj(index)
    arguments
        obj
        PropertyName (1,:) {mustBeText} = 'Num'
        direction {mustBeMember(direction,{'ascend','descend'})} = 'ascend' 
    end
    
    metaobj = metaclass(obj);
    property_props = {metaobj.PropertyList.Name};
    if ~any(strcmp(PropertyName,property_props))
        error('在该类中，没有该属性名，请输入正确的属性名')
    end
    
    unsorted = [obj.(PropertyName)];
    mustBeNumeric(unsorted);
    [~,index] = builtin('sort',unsorted,direction);
    sorted_obj = obj(index);
end