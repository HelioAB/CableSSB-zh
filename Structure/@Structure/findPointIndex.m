function index = findPointIndex(obj,points)
    arguments
        obj
        points (1,:) {mustBeA(points,'Point')}
    end
    if ~isempty(points)
        x = [points.X];
        y = [points.Y];
        z = [points.Z];
        [~,index_cell] = obj.Point.findPointByCoord(x,y,z);
        index = zeros(1,length(obj.Point));
        for i=1:length(index_cell)
            index(index_cell{i}) = i;
        end
    else
        index = [];
    end
end