function [AppliedPoints,XForce,YForce,ZForce] = getConcentratedForceInfo(obj)
    load_list = obj.LoadList;
    AppliedPoints = [];
    for i=1:length(load_list)
        load = load_list{i};
        AppliedPoints = [AppliedPoints,load.AppliedPosition];
    end
    AppliedPoints = AppliedPoints.unique;
    count_point = length(AppliedPoints);
    XForce = zeros(1,count_point);
    YForce = zeros(1,count_point);
    ZForce = zeros(1,count_point);
    for i=1:length(load_list)
        load = load_list{i};
        applied_point = load.AppliedPosition;
        for j=1:length(applied_point)
            index = applied_point(j)==AppliedPoints;
            switch load.Direction
                case 'X'
                    XForce(index) = XForce(index) + load.Value{j};
                case 'Y'
                    YForce(index) = YForce(index) + load.Value{j};
                case 'Z'
                    ZForce(index) = ZForce(index) + load.Value{j};
            end
        end
    end
end