% clear all
% clc
% % 全桥模型
% b = CableStayedSuspension_Bridge;
% b.build
% output_method = OutputToAnsys(b,"JobName",'TotalModel',...
%     'WorkPath','C:\Users\Huawei\Desktop\test\01 Total Model',...
%     'MacFilePath','C:\Users\Huawei\Desktop\test\01 Total Model\main.mac',...
%     'ResultFilePath','C:\Users\Huawei\Desktop\test\01 Total Model\findState\result.out');
% b.OutputMethod = output_method;
% % b.plot
% b.output
% format default
% 
% % 去掉缆索模型
% bridge_state = b.getNonCableBridge;
% output_method = OutputToAnsys(bridge_state,"JobName",'NonCableModel',...
%     'WorkPath','C:\Users\Huawei\Desktop\test\00 Test',...
%     'MacFilePath','C:\Users\Huawei\Desktop\test\00 Test\main.mac',...
%     'ResultFilePath','C:\Users\Huawei\Desktop\test\00 Test\result.out');
% bridge_state.OutputMethod = output_method;

% FE_model = bridge_state.OutputMethod.getFiniteElementModel;
element = FE_model.Element;
FE_model.computeDisplacement;
FE_model.completeDisplacement;
NaN_node = FE_model.checkNaNDisplacement;


if isempty(NaN_node)

    % 单元内力（局部坐标系）
    quary_element_num = 738;
    Map_Element = FE_model.Maps.Element;
    quary_element = Map_Element(quary_element_num);
    element_local_force = quary_element.AnsysForceResult;
    local_force_str = sprintf(['单元：编号%d，MYi = %e，MYj = %e，MZi = %e，MZj = %e，\n'],...
                                quary_element.Num,element_local_force(5),element_local_force(11),element_local_force(6),element_local_force(12));
%     local_force_str = sprintf(['单元：编号%d，FXi = %e，FYi = %e，FZi = %e，\n ' ...
%                                 '\t \t \t MXi = %e，MYi = %e，MZi = %e，\n' ...
%                                 '\t \t \t FXj = %e，FYj = %e，FZj = %e，\n' ...
%                                 '\t \t \t MXj = %e，MYj = %e，MZj = %e，\n'],...
%                                 quary_element.Num,element_local_force(1),element_local_force(2),element_local_force(3),...
%                                 element_local_force(4),element_local_force(5),element_local_force(6),...
%                                 element_local_force(7),element_local_force(8),element_local_force(9),...
%                                 element_local_force(10),element_local_force(11),element_local_force(12));
    disp(local_force_str)
    
    % 单元节点位移(整体坐标系)
    quary_element_num = 1;
    Map_Element = FE_model.Maps.Element;
    quary_element = Map_Element(quary_element_num);
    inode = quary_element.INode;
    jnode = quary_element.JNode;
    num_inode = inode.Num;
    num_jnode = jnode.Num;
    inode_global_dis = inode.Displacement_GlobalCoord;
    jnode_global_dis = jnode.Displacement_GlobalCoord;
    inode_str = sprintf(['I节点：编号%d，UX = %e，UY = %e，UZ = %e，\n ' ...
                '\t \t \t RotX = %e，RotY = %e，RotZ = %e'],...
                num_inode,inode_global_dis(1),inode_global_dis(2),inode_global_dis(3),...
                inode_global_dis(4),inode_global_dis(5),inode_global_dis(6));
    jnode_str = sprintf(['J节点：编号%d，UX = %e，UY = %e，UZ = %e，\n ' ...
                '\t \t \t RotX = %e，RotY = %e，RotZ = %e'],...
                num_jnode,jnode_global_dis(1),jnode_global_dis(2),jnode_global_dis(3),...
                jnode_global_dis(4),jnode_global_dis(5),jnode_global_dis(6));
    disp(inode_str)
    disp(jnode_str)

    % 节点位移
    quary_node = 1;
    Map_Node = FE_model.Maps.Node;
    quary_node = Map_Node(quary_node);
    node_global_dis = quary_node.Displacement_GlobalCoord;
    node_str = sprintf(['I节点：编号%d，UX = %e，UY = %e，UZ = %e，\n ' ...
                '\t \t \t RotX = %e，RotY = %e，RotZ = %e'],...
                quary_node.Num,node_global_dis(1),node_global_dis(2),node_global_dis(3),...
                node_global_dis(4),node_global_dis(5),node_global_dis(6));
    disp(node_str)

end