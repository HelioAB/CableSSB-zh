function action(obj)
    % 读取数据
    filetext = fileread(obj.InputFilePath);
    Number_RegularExpression = '[+-]?[\d.]+(?:[EeDd][+-]*\d+)?';

    % 提取 STIFFNESS MATRIX FOR ELEMENT 数据
    stiffness_pattern = '(?<=STIFFNESS MATRIX FOR ELEMENT)([\s\S]*?)(?=\n\s*\n)';
    stiffness_str = regexp(filetext, stiffness_pattern, 'match','all');
    Map_Element2StiffnessMatrix = containers.Map('KeyType','double','ValueType','any');
    for i=1:length(stiffness_str)
        num_cell = regexp(stiffness_str{i}, Number_RegularExpression, 'match','all');
        num_element = str2double(num_cell{1});
        
        matrix = zeros(12,12);
        for j=1:12
            matrix(j,1:12) = str2double(num_cell((j-1)*13+4:(j-1)*13+15));
        end
        Map_Element2StiffnessMatrix(num_element) = matrix;
    end
    obj.Map_Element2StiffnessMatrix = Map_Element2StiffnessMatrix;
    
%     % 提取 APPLIED LOAD VECTOR
%     load_pattern = '(?<=APPLIED LOAD VECTOR FOR ELEM)([\s\S]*?)(?=\n\s*\n)';
%     load_str = regexp(filetext, load_pattern, 'match','all');
%     
%     Map_ElementLoadVector = containers.Map('KeyType','double','ValueType','any');
%     for i=1:length(load_str)
%         num_cell = regexp(load_str{i}, Number_RegularExpression, 'match','all');
%         num_element = str2double(num_cell{1});
%         
%         vector = str2double(num_cell(3:14))';
%         Map_ElementLoadVector(num_element) = vector;
%     end

end