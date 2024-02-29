function [load_list,index] = findLoadByName(obj,LoadName)%%
    [load_list,index] = obj.findObjListByName('Load',LoadName);
end