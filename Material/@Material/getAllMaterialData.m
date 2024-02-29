function [material_data_struct,name,value] = getAllMaterialData(obj)
    material_data_struct = obj.MaterialData.getAllMaterialData();
    name = fieldnames(material_data_struct)';
    value = cell(1,length(name));
    for i=1:length(name)
        value{i} = material_data_struct.(name{i});
    end

end