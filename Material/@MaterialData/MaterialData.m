classdef MaterialData < handle
    % 单位： N,m
    properties
        Unit = struct('Force','N','Distance','m')
        MaterialType
    end
    methods
        function obj = MaterialData(MaterialType)
            arguments
                MaterialType (1,:) {mustBeText}
            end
            obj.MaterialType = MaterialType;
        end
        tf = isempty(obj)
    end
    methods(Abstract)
        material_data_struct = outputToAnsys(obj) % 输出一个struct，包含且仅包含所有材料参数的参数名和参数值
    end
end