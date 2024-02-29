function Pz = getAverageGirderWeight(obj)
    % 计算总梁重
    weight = obj.getGirderWeight;

    % 计算平均分配到每个斜拉索、吊索上的重量
    count_stayedcable = obj.OriginalBridge.getLineCountOfClass('StayedCable');
    count_hanger = obj.OriginalBridge.getLineCountOfClass('Hanger');
    Pz = weight / (count_stayedcable + count_hanger);
end