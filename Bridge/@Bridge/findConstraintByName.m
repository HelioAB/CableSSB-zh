function [constraint_list,index] = findConstraintByName(obj,ConstraintName)%%
    [constraint_list,index] = obj.findObjListByName('Constraint',ConstraintName);
end