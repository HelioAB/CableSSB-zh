function map = getMap(obj)
    map = containers.Map('KeyType','double','ValueType','any');
    for i=1:length(obj)
        map(obj(i).Num) = obj(i);
    end
end