classdef OutputToRhino < OutputTo
    properties
        FilePath
        LayerInformation
    end
    properties(Constant)
    end
    methods
        function obj = OutputToRhino(OutputObj,options)
            arguments
                OutputObj = Bridge.empty
                options.FilePath (1,:) {mustBeText} = pwd
            end
            % 继承
            obj = obj@OutputTo(OutputObj);
            obj.FilePath = options.FilePath;
        end
        action(obj);
    end
end