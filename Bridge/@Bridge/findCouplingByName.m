function [coupling_list,index] = findCouplingByName(obj,CouplingName)%%
    [coupling_list,index] = obj.findObjListByName('Coupling',CouplingName);
end