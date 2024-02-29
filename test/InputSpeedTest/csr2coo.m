function coo_matrix = csr2coo(csr_row_pointers,csr_col_indices,csr_values)

    % 获取矩阵的行数
    num_rows = length(csr_row_pointers) - 1;

    % 初始化COO格式的输出数组
    coo_row_indices = zeros(size(csr_values));
    coo_col_indices = csr_col_indices;
    coo_values = csr_values;
    pointer = 1;

    % 遍历CSR格式的row_pointers数组
    for row = 1:num_rows
        % 计算当前行的非零元素数量
        num_nonzeros = csr_row_pointers(row+1) - csr_row_pointers(row);
        % 为COO格式的row_indices数组分配相应的行索引值
        coo_row_indices(pointer:pointer+num_nonzeros-1) = repmat(row,1,num_nonzeros);
        % 指示器
        pointer = pointer + num_nonzeros;
    end
    
    % 转换成稀疏矩阵
    coo_matrix = sparse(coo_row_indices,coo_col_indices,coo_values);
end