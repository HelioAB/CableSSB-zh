function P_z = getAverageGirderWeight(obj,GirderList,HangerList,StayedCableList)
    arguments
        obj
        GirderList = obj.findStructureByClass('Girder')
        HangerList = obj.findStructureByClass('Hanger')
        StayedCableList = obj.findStructureByClass('StayedCable')
    end
    % 计算梁重
    weight = getGirderWeight(obj,GirderList);

    % 计算每一个Hanger和StayedCable平均分摊到的重量(直接平均分配)
    count_hanger = 0;
    count_stayedCable = 0;
    if length(HangerList) > 0
        for i=1:length(HangerList)
            hanger = HangerList{i};
            count_hanger = count_hanger + length(hanger.Line);
        end
    else
        count_hanger = 0;
    end
    
    if length(StayedCableList) > 0
        for i=1:length(StayedCableList)
            stayecable = StayedCableList{i};
            count_stayedCable = count_stayedCable + length(stayecable.Line);
        end
    else
        count_stayedCable = 0;
    end
    
    if count_stayedCable + count_hanger > 0
        P_z = weight/(count_stayedCable + count_hanger);
    else
        P_z = [];
    end
end