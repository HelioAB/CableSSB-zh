function coupling = addCoupling(obj,MasterPoint,SlavePoint,DoF,options)
    arguments
        obj
        MasterPoint
        SlavePoint
        DoF
        options.Name {mustBeText} = ''
    end
    coupling = Coupling(MasterPoint,SlavePoint,DoF);
    coupling.record;
    obj.addToList('Coupling',coupling);

    coupling_count = length(obj.CouplingList);
    if isempty(options.Name)
        coupling.Name = ['Coupling','_',num2str(coupling_count)]; % StructureName的默认值：先把StructureObj放进StructureList，再计数
    else
        coupling.Name = char(options.Name);
    end
    params_name = fieldnames(obj.Params);
end