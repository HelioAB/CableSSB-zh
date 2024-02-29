function output_str = outputForce(obj,output_method,X,Pz)
    output_str = ['/prep7',newline];
    % 输出斜拉索代替拉力
    stayed_cable = obj.findStructureByClass('StayedCable');
    count_stayedcable = 0;
    for i=1:length(stayed_cable)
        count_stayedcable = count_stayedcable + length(stayed_cable{i}.Line);
    end

    GirderPointList = [];
    TowerPointList = [];
    AreaList = zeros(1,length(count_stayedcable));
    DensityList = zeros(1,length(count_stayedcable));
    ExList = zeros(1,length(count_stayedcable));
    NumIndexList = zeros(1,length(count_stayedcable));
    for i=1:length(stayed_cable)
        [~,index] = obj.getGirderPz(stayed_cable{i},X,Pz);
        num_index = LogicalIndex2NumIndex(index);
        len = length(num_index);
        GirderPointList = [GirderPointList,stayed_cable{i}.findGirderPoint];
        TowerPointList = [TowerPointList,stayed_cable{i}.findTowerPoint];
        AreaList(end+1:end+len) = [stayed_cable{i}.Section.Area];
        DensityList(end+1:end+len) = stayed_cable{i}.Material.MaterialData.density + zeros(1,len);
        ExList(end+1:end+len) = stayed_cable{i}.Material.MaterialData.E + zeros(1,len);
        NumIndexList(end+1:end+len) = num_index(index);
    end
end