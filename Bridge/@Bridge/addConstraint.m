function constraint = addConstraint(obj,ConstraintPoint,DoF,Value,options)
    arguments
        obj
        ConstraintPoint
        DoF
        Value
        options.Name {mustBeText} = ''
    end
    constraint = Constraint(ConstraintPoint,DoF,Value);
    constraint.record;
    obj.addToList('Constraint',constraint);
    constraint_count = length(obj.ConstraintList);
    if isempty(options.Name)
        constraint.Name = ['Constraint','_',num2str(constraint_count)]; % StructureName的默认值：先把StructureObj放进StructureList，再计数
    else
        constraint.Name = char(options.Name);
    end
    params_name = fieldnames(obj.Params);
end