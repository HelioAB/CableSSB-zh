function [unipoint,index_IPoint,index_JPoint] = uniPoint(obj)
    len = length(obj);
    ipoint = [obj.IPoint];
    jpoint = [obj.JPoint];
    allPoints = [ipoint,jpoint];

    [unipoint,~,uni2obj] = unique(allPoints);
    index_IPoint = uni2obj(1:len);
    index_JPoint = uni2obj(len+1:2*len);
end