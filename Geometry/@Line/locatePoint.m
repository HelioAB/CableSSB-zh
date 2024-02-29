function [index_IPoint,index_JPoint] = locatePoint(obj,point)
    arguments
        obj
        point (1,:) {mustBeA(point,'Point')}
    end
    ipoint = [obj.IPoint];
    jpoint = [obj.JPoint];
    index_IPoint = cell(1,length(point));
    index_JPoint = cell(1,length(point));
    for i=1:length(point)
        index_IPoint{i} = ipoint == point(i);
        index_JPoint{i} = jpoint == point(i);
    end
end