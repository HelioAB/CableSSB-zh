clear all
clc

%%
MainPath = genpath('.\'); % 当前工作路径下的所有文件夹
addpath(MainPath)
%%
clear all
clc

b = CableStayedSuspension_Bridge; % 斜拉-悬索协作体系桥
b.build;

newfolder = 'C:\Users\11440\Desktop\usage\CableSuspensionBridge\test';
b.OutputMethod.WorkPath = 'C:\Users\11440\Desktop\usage\CableSuspensionBridge\test';
b.OutputMethod.JobName = 'CableStayedSuspension_Bridge';
b.OutputMethod.MacFilePath = [newfolder,'\main.mac'];
b.OutputMethod.ResultFilePath = [newfolder,'\result.out'];
b.OutputMethod.AnsysPath = 'C:\Program Files\ANSYS Inc\ANSYS Student\v232\commonfiles\launcherQT\source\..\..\..\ansys\bin\winx64\MAPDL.EXE';

b.output

b.plot

%% 斜拉桥例子
clear all
clc
b = CableStayed_Bridge;
b.build;

newfolder = ['S:\03 软著\何力 软著书写\图','\CableStayed_Bridge'];
mkdir(newfolder)
b.OutputMethod.WorkPath = newfolder;
b.OutputMethod.JobName = 'CableStayed_Bridge';
b.OutputMethod.MacFilePath = [newfolder,'\main.mac'];
b.OutputMethod.ResultFilePath = [newfolder,'\result.out'];

b.output
b.plot

%% 悬索桥例子
clear all
clc
b = Suspension_Bridge;
b.build;

newfolder = ['S:\03 软著\何力 软著书写\图','\Suspension_Bridge'];
mkdir(newfolder)
b.OutputMethod.WorkPath = newfolder;
b.OutputMethod.JobName = 'Suspension_Bridge';
b.OutputMethod.MacFilePath = [newfolder,'\main.mac'];
b.OutputMethod.ResultFilePath = [newfolder,'\result.out'];


b.output
b.plot

%% 
clear all
clc
b = CableStayedSuspension_Bridge;
b.build;
b.OutputMethod.outputPostProcessing
[bridge_findState_final,U_final] = b.optimBendingStrainEnergy();
bridge_findState_final.output
bridge_findState_final.plot
%%
clear all
clc
b = CableStayed_Bridge;
b.build;
output_method = OutputToAnsys(b,"JobName",'CableStayedBridge_01', ...
                                'MacFilePath','C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\CableStayed\main.ac',...
                                'WorkPath','C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\CableStayed',...
                                'ResultFilePath','C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\CableStayed\result.out');
b.OutputMethod = output_method;
b.output;

%%
clear all
clc
b = CableStayedSuspension_Bridge;
b.build;
bridge_findState = b.getNonCableBridge();
bridge_findState.output;
bridge_findState.run
output_method = bridge_findState.OutputMethod;
tower = bridge_findState.findStructureByClass('Tower');
girder = bridge_findState.findStructureByClass('Girder');
structure_list = [tower,girder];

DataBasePath = [output_method.WorkPath,'\',output_method.JobName,'.db'];
ResultFilePath = output_method.getBendingStrainEnergy(structure_list,DataBasePath)


%%
clear all
clc

b = StayedCableBridge_span(70*10);
b.plot
b.output

b = StayedCableBridge_span(70*7.5);
b.plot
view([-1,-1,-1])
b.output

b = StayedCableBridge_span(70*12.5);
b.plot
view([-1,-1,-1])
b.output

% matlab:
%   view([-1,-1,-1])
% ansys:
%   /view,1,-1,-1,1
%   /replot
%   /angle,1,-90,XM
%   /replot

%%
clear all
clc
[obj,f] = SuspensionBridge_span(4.8)
obj.plot
view([-1,-1,-1])

clear all
clc
[obj,f] = SuspensionBridge_span(24.8)
obj.plot
view([-1,-1,-1])

clear all
clc
[obj,f] = SuspensionBridge_span(44.8)
obj.plot
view([-1,-1,-1])

%%
clear all
clc
obj = HybridBridge_CrossHanger(0);
obj.plot
view([-1,-1,-1])

clear all
clc
obj = HybridBridge_CrossHanger(3);
obj.plot
view([-1,-1,-1])

clear all
clc
obj = HybridBridge_CrossHanger(6);
obj.plot
view([-1,-1,-1])

%%
clear all
clc
obj = HybridBridge_Rise(102.35);
obj.plot

%%
clear all
clc
obj = HybridBirgde_NonHanger();
obj.output

clear all
clc
obj = HybridBirgde_NonCableSystem();
obj.output

b1 = b.getNonCableBridge

%% 
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
% b.plot
b.output
format default

% 去掉缆索模型
bridge_state = NoCable_Bridge(b);
bridge_state.build
output_method = OutputToAnsys(bridge_state,"JobName",'NonCableModel',...
    'AnsysPath','C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe',...
    'WorkPath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge',...
    'MacFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge\main.mac',...
    'ResultFilePath','C:\Users\11440\Desktop\usage\CableSuspensionBridge\NC_Bridge\result.out');
bridge_state.OutputMethod = output_method;
[FEModel,isCompleted] = bridge_state.getFiniteElementModel;

% 
