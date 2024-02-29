function plotCoupling(obj,fig,ax)
    len = length(obj.CouplingList);
    if len~=0
        for i=1:len
            obj.CouplingList{i}.plot('Figure',fig,'Axis',ax);
        end
    end
    
end