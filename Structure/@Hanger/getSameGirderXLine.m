function [LineList,X,RowIndex,ColumnIndex] = getSameGirderXLine(obj)
    count_structure = length(obj);
    XCoordCell = cell(1,count_structure);
    LineCell = cell(1,count_structure);
    for i=1:count_structure
        structure = obj(i);
        IPoint = [structure.Line.IPoint];
        JPoint = [structure.Line.JPoint];
        IPoint_Coord = IPoint.Coord;
        JPoint_Coord = JPoint.Coord;
        if IPoint_Coord(:,3) > JPoint_Coord(:,3)
            XCoordCell{i} = JPoint_Coord(:,1)';
        else
            XCoordCell{i} = IPoint_Coord(:,1)';
        end
        LineCell{i} = structure.Line;
    end
    XCoordMatrix = concatenate_vectors(XCoordCell);
    X = unique(XCoordMatrix);
    LineList = cell(1,length(X));
    RowIndex = cell(1,length(X));
    ColumnIndex = cell(1,length(X));
    for i=1:length(X)
        XCoord = X(i);
        index = XCoordMatrix==XCoord;
        [row,col] = find(index);
        lines = [];
        for j=1:length(row)
            lines = [lines,LineCell{row(j)}(col(j))];
        end
        LineList{i} = lines;
        RowIndex{i} = row';
        ColumnIndex{i} = col';
    end
end
function mat = concatenate_vectors(cell_array_of_vectors)
    % 使用方式
    %{
    v1 = [1, 2, 3];
    v2 = [4, 5];
    v3 = [6, 7, 8, 9];
    cell_array_of_vectors = {v1, v2, v3};
    mat = concatenate_vectors(cell_array_of_vectors);
    %}

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