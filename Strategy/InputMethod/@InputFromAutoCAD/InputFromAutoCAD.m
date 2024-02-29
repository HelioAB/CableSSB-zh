classdef InputFromAutoCAD < InputFrom
    properties
        LineList
    end
    methods
        function obj = InputFromAutoCAD(filepath)
            obj = obj@InputFrom(filepath);

            % 输入文件类型限制
            splitted_char = split(obj.InputFilePath,'.');
            file_type = splitted_char{end};
            allowable_file_type = {'txt','m'};
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
        
        RawData = txtToRawData(obj,row_delimiter,column_delimiter)
        [line_list] = RawData2LineList(obj)
        line_list = action(obj)
    end
end