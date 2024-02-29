classdef InputAnsysElementStiffnessMatrix < InputFrom
    properties
        Map_Element2StiffnessMatrix
    end
    methods
        function obj = InputAnsysElementStiffnessMatrix(file_path)
            obj = obj@InputFrom(file_path);

            % 输入文件类型限制
            splitted_char = split(obj.InputFilePath,'.');
            file_type = splitted_char{end};
            allowable_file_type = {'txt','out'};
            tf = false;
            error_text = '输入文件必须为以下文件类型之一：';
            for i=1:length(allowable_file_type)
                if strcmp(allowable_file_type{i},file_type)
                    tf = true;
                end
                error_text = [error_text,'.',allowable_file_type{i},', '];
            end
            if ~tf
                error(error_text(1:end-2))
            end
        end
        action(obj)
    end
end
