function RawData = txtToRawData(obj,begin_row,row_delimiter,column_delimiter) % 不同的InputFrom类有不同的数据处理方法
    arguments
        obj
        begin_row {mustBeInteger} = 2 % 从第2行开始读
        row_delimiter {mustBeText} = '\n' % 行间通过 '\n'分割
        column_delimiter {mustBeText} = '\t'% 列间通过 '\t'分割
    end
    % 导入.txt文件的格式
    % 端点X     端点Y     端点Z     起点X     起点Y     起点Z
    % 157.5000  0.0000   77.8000   157.5000  0.0000   75.8000
    % 规定： 所有导入的数据经过txtToRawData()方法处理过后, 需要满足以下所有格式：
    %   1. obj.RawData的一行表示：一条线IPoint, JPoint点的坐标，排序方式为Xi,Yi,Zi,Xj,Yj,Zj
    %   2. obj.RawData为double类型的矩阵
    %   3. obj.RawData没有NaN数据
    RawData_str = fileread(obj.InputFilePath);
    RawData_str_cell = strsplit(strip(RawData_str),row_delimiter);
    RawData = [];
    for i=begin_row:length(RawData_str_cell) % 去掉第一行表头，只保留数值
        str_line = strip(RawData_str_cell{i});
        str_point_coord = strsplit(str_line,column_delimiter);
        Point_coord = zeros(1,length(str_point_coord));
        for j=1:length(Point_coord)
            Point_coord(j) = str2num(str_point_coord{j});
        end
        RawData = [RawData;Point_coord];
    end
    obj.RawData = RawData; 
end