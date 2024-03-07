% clear all
% clc
% % 全桥模型
% b = CableStayedSuspension_Bridge;
% b.build
% output_method = OutputToAnsys(b,"JobName",'TotalModel',...
%     'AnsysPath','C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe',...
%     'WorkPath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\CS_Bridge',...
%     'MacFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\CS_Bridge\main.mac',...
%     'ResultFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\CS_Bridge\result.out');
% b.OutputMethod = output_method;
% 
% % 去掉缆索模型
% bridge_state = NoCable_Bridge(b);
% bridge_state.build
% output_method = OutputToAnsys(bridge_state,"JobName",'NonCableModel',...
%     'AnsysPath','C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe',...
%     'WorkPath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge',...
%     'MacFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge\main.mac',...
%     'ResultFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge\result.out');
% bridge_state.OutputMethod = output_method;
% [FEModel,isEquationCompleted] = bridge_state.getFiniteElementModel;

% 对弯曲应变能优化
% bridge_state.optimBendingStrainEnergy('MaxIter',2,'DiffMinChange',1e4);

% 求解三维主缆形状
bridge_state.solveCableShape;