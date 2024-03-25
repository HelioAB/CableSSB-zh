function output_str = outputConstraint(obj,fileName)
    arguments
        obj
        fileName = 'defConstraint.mac'
    end
    constraint_list = obj.OutputObj.ConstraintList;
    % 输出的APDL字符串
    output_str = '';
    for i=1:length(constraint_list)
        constraintObj = constraint_list{i};
        dofs = constraintObj.DoF;
        output_str = [output_str,'!Constraint Name: ',constraintObj.Name,newline];
        for j=1:length(dofs)
            dof = dofs(j);
            output_str = [output_str,sprintf(['allsel $ ksel,s,,,%d $ nslk,s $ d,all,%s,%f'],constraintObj.Point.Num,char(dof),constraintObj.Value(j)),newline];
        end
        output_str = [output_str,newline];
    end
    output_str = [output_str,'allsel',newline];
    % 输出到defConstraint.mac
    obj.outputAPDL(output_str,fileName,'w')
end