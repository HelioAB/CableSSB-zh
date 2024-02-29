function action(obj)
    % 导入数据
    obj.Txt2RawData();
    % 转换成稀疏矩阵
    csr_row_indices = obj.RawData.csr_row_indices;
    csr_col_indices = obj.RawData.csr_col_indices;
    csr_values = obj.RawData.csr_values;
    obj.StiffMatrix = obj.csr2coo(csr_row_indices,csr_col_indices,csr_values);
end