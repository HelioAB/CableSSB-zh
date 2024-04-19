classdef OutputToRhino < OutputTo
    properties
        Path_Output
        Path_RelativePython
        LayerInformation = struct
    end
    properties(Constant)
    end
    methods
        function obj = OutputToRhino(OutputObj,Path_Output)
            arguments
                OutputObj = Bridge.empty
                Path_Output (1,:) {mustBeText} = pwd
            end
            % 继承
            obj = obj@OutputTo(OutputObj);
            obj.Path_Output = Path_Output;

            % 三个python工具程序的位置
            Path_currentFunction = mfilename('fullpath');
            splitted_str = strsplit(Path_currentFunction,'CableSSB-zh');
            Path_untils = fullfile(splitted_str{1},'CableSSB-zh','utils');
            obj.Path_RelativePython = struct;
            obj.Path_RelativePython.step01_InputDataFromExcel = fullfile(Path_untils,'01_InputDataFromExcel.py');
            obj.Path_RelativePython.step01_ChangeColor = fullfile(Path_untils,'02_ChangeColor.py');
            obj.Path_RelativePython.step03_ObliqueAxonometricDrawing = fullfile(Path_untils,'03_ObliqueAxonometricDrawing.py');
        end
        action(obj);
    end
end