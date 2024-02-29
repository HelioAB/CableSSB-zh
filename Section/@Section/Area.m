function A = Area(obj)
    len = length(obj);
    A = zeros(1,len);
    for i=1:len
        A(i) = obj(i).SectionData.Area;
    end
end