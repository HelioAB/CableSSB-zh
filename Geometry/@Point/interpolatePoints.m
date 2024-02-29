function InterpolatedPoints = interpolatePoints(obj,options)
    arguments
        obj
        options.Ratio (1,:) {mustBeNumeric} = []
        options.Count (1,1) {mustBeNumeric} = 0 % 均匀内插多少个Point对象，例如内插1个相当于options.Ratio = [1/2,1/2]
        options.ReferencePoint {mustBeA(options.ReferencePoint,'Point')} = Point.empty% 通过参考点，线性内插
        options.Interval (1,:) {mustBeNumeric} = []
    end

    if ~isempty(options.Ratio)
        InterpolatedPoints = interpolateByRatio(obj,options.Ratio);
    end

    if options.Count~=0 % 待实现
        InterpolatedPoints = [];
    end
    
    if ~isempty(options.ReferencePoint) % 待实现
        InterpolatedPoints = [];
    end

    if ~isempty(options.Interval)
        Ratio = options.Interval/sum(options.Interval);
        InterpolatedPoints = interpolateByRatio(obj,Ratio);
    end

end
function InterpolatedPoints = interpolateByRatio(obj,Ratio)
    IPoint = obj(1);
    JPoint = obj(2);
    ICoord = IPoint.Coord;
    JCoord = JPoint.Coord;
    IX = ICoord(1);
    IY = ICoord(2);
    IZ = ICoord(3);
    JX = JCoord(1);
    JY = JCoord(2);
    JZ = JCoord(3);

    len = length(Ratio);

    X = IX + zeros(1,len+1);
    Y = IY + zeros(1,len+1);
    Z = IZ + zeros(1,len+1);

    for i=1:len
        X(i+1) = X(i)+(JX-IX)*Ratio(i);
        Y(i+1) = Y(i)+(JY-IY)*Ratio(i);
        Z(i+1) = Z(i)+(JZ-IZ)*Ratio(i);
    end
    if len>=2
        InterpolatedPoints = Point([],X(2:end-1),Y(2:end-1),Z(2:end-1));
    else
        InterpolatedPoints = [];
    end
end