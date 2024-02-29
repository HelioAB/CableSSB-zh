function num_index = LogicalIndex2NumIndex(logical_index)
    % 输入的logical_index为cell，cell的每一个元素都是一个logical
    num_index = zeros(1,length(logical_index));
    for i=1:length(logical_index)
        if logical_index(i)
            num_index(i) = i;
        end
    end
end