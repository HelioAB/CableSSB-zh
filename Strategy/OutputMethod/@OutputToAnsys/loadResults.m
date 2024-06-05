function [data,nodes,elems_link,elems_beam] = loadResults(obj,options)
    arguments
        obj
        options.ResultType {mustBeMember(options.ResultType,{'Displacement','InternalForce','InfluenceLine'})}
        options.ifReload = true
    end
    path_bridge = obj.WorkPath;
    if isempty(obj.OutputObj)
        obj.loadBridgeObj('ifReplaceOutputObj',true);
    end
    path_result = fullfile(path_bridge,sprintf('Result_%s',options.ResultType),'ResultData.mat');
    bridgeobj = obj.OutputObj;
    nodes = [];
    elems_link  = [];
    elems_beam = [];

    switch options.ResultType
        case 'Displacement'
            if exist(path_result,'file') && ~options.ifReload
                result = load(path_result,'data');
                data = result.data;
            else
                data = obj.getDisplacementFromAnsys([bridgeobj.getAllNodes.Num]);
            end
            nodes = allocateDisplacementToNodes(bridgeobj,data);
        case 'InternalForce'
            if exist(path_result,'file') && ~options.ifReload
                result = load(path_result,'data');
                data = result.data;
            else
                data = obj.getInternalForceFromAnsys([bridgeobj.getAllLinks.Num],[bridgeobj.getAllBeams.Num]);
            end
            [elems_link,elems_beam] = allocateInternalForceToElement(bridgeobj,data);
        case 'InfluenceLine'
            %
    end

end
function nodes = allocateDisplacementToNodes(bridgeobj,result_Displacement)
    nodes = bridgeobj.getAllNodes();
    num_nodes = result_Displacement.num_nodes;
    Ux = result_Displacement.Ux;
    Uy = result_Displacement.Uy;
    Uz = result_Displacement.Uz;
    Rotx = result_Displacement.Rotx;
    Roty = result_Displacement.Roty;
    Rotz = result_Displacement.Rotz;
    for i=1:length(nodes)
        node = nodes(i);
        index = node.Num == num_nodes;
        node.Displacement_GlobalCoord(1:6,1) = [Ux(index);Uy(index);Uz(index);...
                                                Rotx(index);Roty(index);Rotz(index)];
    end
end
% 将InternaoForce赋予Element
function [elems_link,elems_beam] = allocateInternalForceToElement(bridgeobj,result_InternalForce)
    elems_link = bridgeobj.getAllLinks();
    num_elements_link = result_InternalForce.num_elements_link;
    Fxi_link = result_InternalForce.Fx_link;
    Fxj_link = result_InternalForce.Fx_link;
    for i=1:length(elems_link)
        elem = elems_link(i);
        index = elem.Num == num_elements_link;
        vector_force = [Fxi_link(index);Fxj_link(index);0;...
                        0;0;0;...
                        0;0;0;...
                        0;0;0];
        elem.setForce_LocalCoord(vector_force)
    end
    elems_beam = bridgeobj.getAllBeams();
    num_elements_beam = result_InternalForce.num_elements_beam;
    Fxi_beam = result_InternalForce.Fxi_beam;
    Fyi_beam = result_InternalForce.Fyi_beam;
    Fzi_beam = result_InternalForce.Fzi_beam;
    Mxi_beam = result_InternalForce.Mxi_beam;
    Myi_beam = result_InternalForce.Myi_beam;
    Mzi_beam = result_InternalForce.Mzi_beam;
    Fxj_beam = result_InternalForce.Fxj_beam;
    Fyj_beam = result_InternalForce.Fyj_beam;
    Fzj_beam = result_InternalForce.Fzj_beam;
    Mxj_beam = result_InternalForce.Mxj_beam;
    Myj_beam = result_InternalForce.Myj_beam;
    Mzj_beam = result_InternalForce.Mzj_beam;
    for i=1:length(elems_beam)
        elem = elems_beam(i);
        index = elem.Num == num_elements_beam;
        vector_force = [Fxi_beam(index);Fyi_beam(index);Fzi_beam(index);...
                        Mxi_beam(index);Myi_beam(index);Mzi_beam(index);...
                        Fxj_beam(index);Fyj_beam(index);Fzj_beam(index);...
                        Mxj_beam(index);Myj_beam(index);Mzj_beam(index)];
        elem.setForce_LocalCoord(vector_force)
    end    
end
