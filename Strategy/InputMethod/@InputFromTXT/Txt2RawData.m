function RawData = Txt2RawData(obj,num_column,RegularExpression)
    arguments
        obj
        num_column {mustBeInteger}
        RegularExpression {mustBeText} = '[+-]?[\d.]+(?:[Ee][+-]*\d+)?' % 匹配纯数字和科学计数法的正则表达式
    end
    filetext = fileread(obj.InputFilePath);
    matches = regexp(filetext,RegularExpression,'match');
    data_one_line = str2double(matches);
    RawData_t = reshape(data_one_line,num_column,[]);
    RawData = RawData_t';
end