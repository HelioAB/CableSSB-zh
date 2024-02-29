classdef InputAnsysGlobalStiffnessMatrix < InputFrom
    properties
        StiffMatrix % matlab中的sparse类型
        RHS
    end
    methods
        function obj = InputAnsysGlobalStiffnessMatrix(file_path)
            obj = obj@InputFrom(file_path);

            % 输入文件类型限制
            splitted_char = split(obj.InputFilePath,'.');
            file_type = splitted_char{end};
            allowable_file_type = {'txt'};
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
        Txt2RawData(obj)
        coo_matrix = csr2coo(obj,csr_row_pointers,csr_col_indices,csr_values)
    end
end
