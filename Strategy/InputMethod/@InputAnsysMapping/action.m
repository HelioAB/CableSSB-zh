function action(obj)
    filetext = fileread(obj.InputFilePath);
    stiffness_pattern = '(\d+)\s+(\d+)\s+(\w+)';
    stiffness_str = regexp(filetext, stiffness_pattern,'tokens');
    len = length(stiffness_str);
    MatrixEquation_col = zeros(1,len);
    Node_col = zeros(1,len);
    DoF_col = cell(1,len);
    Map_Equation2NodeDoF = containers.Map('KeyType','double','ValueType','any');
    Map_Node2DoFEquation = containers.Map('KeyType','double','ValueType','any');
    for i=1:length(stiffness_str)
        
        MatrixEquation_col(i) = str2double(stiffness_str{i}(1));
        Node_col(i) = str2double(stiffness_str{i}(2));
        DoF_col(i) = stiffness_str{i}(3);
        NodeDoF = struct('Node',Node_col(i),'DoF',DoF_col(i));
        Map_Equation2NodeDoF(MatrixEquation_col(i)) = NodeDoF;

        if isKey(Map_Node2DoFEquation,Node_col(i))
            dof = Map_Node2DoFEquation(Node_col(i));
        else
            dof = zeros(1,6);
        end
        switch DoF_col{i}
            case 'UX'
                dof(1) = MatrixEquation_col(i);
            case 'UY'
                dof(2) = MatrixEquation_col(i);
            case 'UZ'
                dof(3) = MatrixEquation_col(i);
            case 'ROTX'
                dof(4) = MatrixEquation_col(i);
            case 'ROTY'
                dof(5) = MatrixEquation_col(i);
            case 'ROTZ'
                dof(6) = MatrixEquation_col(i);
        end
        Map_Node2DoFEquation(Node_col(i)) = dof;
    end
    obj.MatrixEquation = MatrixEquation_col;
    obj.Node = Node_col;
    obj.DOF = DoF_col;
    obj.Map_Equation2NodeDoF = Map_Equation2NodeDoF;
    obj.Map_Node2DoFEquation = Map_Node2DoFEquation;
end
function merged_struct = mergestruct(struct1,struct2)
    
end