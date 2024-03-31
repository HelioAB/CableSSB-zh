function new_obj = clone(obj)
    new_obj = FiniteElementModel(obj.BridgeModel,obj.Node,obj.Element,obj.Maps);
end