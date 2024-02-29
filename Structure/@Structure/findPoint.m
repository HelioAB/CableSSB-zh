function point_list = findPoint(obj,SearchingMethod,Component,Direction,ByValue)
    arguments
        obj
        SearchingMethod {mustBeMember(SearchingMethod,{'Interval','Index'})}
        Component {mustBeMember(Component,{'X','Y','Z'})}
        Direction {mustBeMember(Direction,{'ascend','descend'})}
        ByValue {mustBeNumericOrLogical}
    end
    switch SearchingMethod
        case 'Interval'
            point_list = findPointByInterval(obj,Component,ByValue,Direction);
        case 'Index'
            point_list = findPointByIndex(obj,Component,ByValue,Direction);
    end
end

function point_list = findPointByInterval(obj,component,interval,direction)
    % length(point) == length(interval)
    % 如果要输出Girder的第一个点，interval的第1个元素应设为0
    arguments
        obj
        component
        interval (1,:) {mustBeNumeric}
        direction {mustBeMember(direction,{'ascend','descend'})} = 'ascend'
    end
    if ~isempty(interval)
        len = length(interval);
        point_list(1,len) = Point();% 创建长度为length(interval)的Point对象数组
        AllPoint = obj.Point.sort(component,direction);
        current_component = AllPoint(1).(component);
        for i=1:len
            if strcmp(direction,'ascend')
                point = AllPoint.findPointByRange(current_component+interval(i),[],[]);
                current_component = current_component + interval(i);
            else
                point = AllPoint.findPointByRange(current_component-interval(i),[],[]);
                current_component = current_component - interval(i);
            end
            point_list(1,i) = point;
            if isempty(point)
                error(['没有找到：interval的第',num2str(i),'个间距所对应的点'])
            end
        end
    else
        point_list = Point.empty;
    end
end
function point_list = findPointByIndex(obj,component,index,direction)
    arguments
        obj
        component
        index (1,:) {mustBeNumericOrLogical}
        direction {mustBeMember(direction,{'ascend','descend'})} = 'ascend'
    end
    if ~isempty(index)
        AllPoint = obj.Point.sort(component,direction);
        point_list = AllPoint(index);
    else
        point_list = Point.empty;
    end
end 