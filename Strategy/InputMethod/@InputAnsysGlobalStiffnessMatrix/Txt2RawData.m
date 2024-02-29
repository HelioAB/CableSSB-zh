function Txt2RawData(obj)
    % 读取数据
    filetext = fileread(obj.InputFilePath);
    splitted_text = splitlines(filetext);
    RegularExpression = '[+-]?[\d.]+(?:[EeDd][+-]*\d+)?';% 匹配纯数字和科学计数法的正则表达式

    % 说明行
    description_line = splitted_text{2};
    matches = regexp(description_line,RegularExpression,'match');
    count_line_max = str2double(matches{1}); % 文件的总行数
    count_row = str2double(matches{2}); % CSR格式，列数
    count_col = str2double(matches{3}); % CSR格式，行数
    count_value = str2double(matches{4}); % CSR格式，值数
    count_RHS = str2double(matches{5}); % CSR格式，RHS数，通常是列数-1
    
    % 初始化
    csr_row_indices = zeros(1,count_row);
    csr_col_indices = zeros(1,count_col);
    csr_value = zeros(1,count_value);
    RHS = zeros(count_RHS,1);
    line_row_indices = splitted_text(6:6+count_row-1);
    line_col_indices = splitted_text(6+count_row:6+count_row+count_col-1);
    line_value = splitted_text(6+count_row+count_col:6+count_row+count_col+count_value-1);
    line_RHS = splitted_text(6+count_row+count_col+count_value:6+count_row+count_col+count_value+count_RHS-1);

    % 读取文件中的数据并赋值到Matlab中
    csr_row_indices = str2double(line_row_indices);
    csr_col_indices = str2double(line_col_indices);
    for i=1:count_value
        cell_value = regexp(line_value{i},RegularExpression,'match');
        csr_value(i) = str2num(cell_value{1});
    end
    for i=1:count_RHS
        cell_RHS = regexp(line_RHS{i},RegularExpression,'match');
        RHS(i) = str2num(cell_RHS{1});
    end

    % 存储到obj.RawData中
    obj.RawData.csr_row_indices = csr_row_indices;
    obj.RawData.csr_col_indices = csr_col_indices;
    obj.RawData.csr_values = csr_value;
    obj.RHS = RHS;
end