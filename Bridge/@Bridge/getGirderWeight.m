function weight = getGirderWeight(obj,GirderList)
    arguments
        obj
        GirderList {mustBeA(GirderList,{'Girder','cell'})} = cellfun(@(x) [x],obj.findStructureByClass('Girder'))
    end
    weight_girder = zeros(1,length(GirderList));
    if isa(GirderList,'cell')
        GirderList = cellfun(@(x) [x],GirderList);
    end
    for i=1:length(GirderList)
        % 计算每一个Girder对象的总重
        girder_i = GirderList(i);
        length_list_i = girder_i.Line.DeltaLength;
        Area_list_i = girder_i.Section.Area;
        gamma_i = girder_i.Material.MaterialData.gamma;
        weight_girder(i) = sum(length_list_i.*Area_list_i.*gamma_i);
    end
    weight = sum(weight_girder);
end