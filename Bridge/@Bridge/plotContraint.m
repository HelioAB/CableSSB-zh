function plotContraint(obj,fig,ax)
    len = length(obj.ConstraintList);
    if len~=0
        for i=1:len
            obj.ConstraintList{i}.plot('Figure',fig,'Axis',ax);
        end
    end
    
end