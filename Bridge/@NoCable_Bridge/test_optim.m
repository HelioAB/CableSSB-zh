clear all
clc
% 全桥模型
b = CableStayedSuspension_Bridge;
b.build
output_method = OutputToAnsys(b,"JobName",'TotalModel',...
    'AnsysPath','C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe',...
    'WorkPath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\CS_Bridge',...
    'MacFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\CS_Bridge\main.mac',...
    'ResultFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\CS_Bridge\result.out');
b.OutputMethod = output_method;

% 去掉缆索模型
bridge_state = NoCable_Bridge(b);
bridge_state.build
output_method = OutputToAnsys(bridge_state,"JobName",'NonCableModel',...
    'AnsysPath','C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe',...
    'WorkPath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge',...
    'MacFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge\main.mac',...
    'ResultFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge\result.out');
bridge_state.OutputMethod = output_method;
[FEModel,isEquationCompleted] = bridge_state.getFiniteElementModel;

% 进行优化
bridge_state.optimBendingStrainEnergy('MaxIter',30,'DiffMinChange',1e4);

% 继续优化
% iter = bridge_state.Iter_Optimization;
% iter_U = bridge_state.Result_Iteration.Iter_U;
% iter_Pz = bridge_state.Result_Iteration.Iter_Pz;
% bridge_state.optimBendingStrainEnergy('Initial_Iter',iter,'Initial_Iter_Pz',iter_Pz,'Initial_Iter_U',iter_U,'MaxIter',50,'DiffMinChange',1e4)
% 
% % 调整主塔弯曲应变能关注度，进行索力优化
% % bridge_state_01 = bridge_state.clone;
% % bridge_state_01.optimBendingStrainEnergy
% 
% % 将优化出来的最小弯曲应变能赋予到带缆索的桥梁上，并在Ansys中计算实际的模型
% % iter_Pz = bridge_state.Result_Iteration.Iter_Pz;


% 结果
Map_Pz = bridge_state.Result_Iteration.Iter_Pz;
max_iter = bridge_state.Iter_Optimization;
% 第12008次迭代的索力
Pz_final = Map_Pz(max_iter);
X = bridge_state.OriginalBridge.getSortedGirderPointXCoord([bridge_state.OriginalBridge.findStructureByClass('Hanger'),bridge_state.OriginalBridge.findStructureByClass('StayedCable')]);
bar(X,Pz_final)


% 输出到Ansys中看结果
output_method = OutputToAnsys(bridge_state,"JobName",'NonCableModel',...
    'AnsysPath','C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe',...
    'WorkPath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\Optimed_NC_Bridge',...
    'MacFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\Optimed_NC_Bridge\main.mac',...
    'ResultFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\Optimed_NC_Bridge\result.out');
bridge_state.OutputMethod = output_method;
bridge_state.output

% % 辅助墩固定节点
% num_constraint_point = [103,128];
% num_node = num_constraint_point(1);
% Point2Node = bridge_state.FiniteElementModel.Maps.Point2Node;
% Node2Element = bridge_state.FiniteElementModel.Maps.Node2Element;
% Map_Element = bridge_state.FiniteElementModel.Maps.Element;
% num_element = Node2Element(Point2Node(num_node));
% element = Map_Element(num_element(1));
% element.AnsysForceResult
% % [fig,ax] = bridge_state.plot;
% %  bridge_state.FiniteElementModel.plotBendingMoment('Figure',fig,'Axis',ax);


bridge_state.solveCableShape;

only_cable_bridge = bridge_state.getOnlyCableBridge;
output_method = OutputToAnsys(only_cable_bridge,"JobName",'OnlyCableModel',...
    'AnsysPath','H:\BigSoftwares\Ansys19\ANSYS Inc\v191\ansys\bin\winx64\MAPDL.exe',...
    'WorkPath','C:\Users\Heli\Desktop\test\03 Only Cable Model',...
    'MacFilePath','C:\Users\Heli\Desktop\test\03 Only Cable Model\main.mac',...
    'ResultFilePath','C:\Users\Heli\Desktop\test\03 Only Cable Model\result.out');
only_cable_bridge.OutputMethod = output_method;
only_cable_bridge.output

b.output

% 检查轴力的竖向分力
stayed_cable_list = b.findStructureByClass('StayedCable');
stayed_cable_list = bridge_state.ReplacedStayedCable;
sc1 = stayed_cable_list(1);
sc1.getVerticalForce
sc1.InternalForce
sc1.Strain

hanger_list = b.findStructureByClass('Hanger');
hanger1 = hanger_list{1};
hanger1.getVerticalForce

b.OutputMethod.runMac("MacFilePath",'C:\Users\Heli\Desktop\test\01 Total Model\main.mac')
b.run("MacFilePath",'test.mac')