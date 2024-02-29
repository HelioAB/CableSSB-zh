function mat = concatenate_vectors(cell_array_of_vectors)
    % find the max length
    max_len = max(cellfun(@(x) length(x), cell_array_of_vectors));
    
    % initialize the matrix
    mat = NaN(length(cell_array_of_vectors), max_len);
    
    % fill the matrix
    for k = 1:length(cell_array_of_vectors)
        current_vector = cell_array_of_vectors{k};
        mat(k, 1:length(current_vector)) = current_vector;
    end
end