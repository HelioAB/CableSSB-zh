classdef InputFrom < Strategy
    properties
       RawData
       InputFilePath
    end

    methods
        function obj = InputFrom(file_path)
            arguments
                file_path (1,:) {mustBeText}
            end
            obj.InputFilePath = file_path;
        end
        function action(obj)
        end
        
    end
end