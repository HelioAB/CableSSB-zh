%
clear
clc

obj = CableStayedSuspension_Bridge;

% 主跨主缆：截面、材料、单元类型材料
main_cable_sectiondata = CircleSection(0.36/2); % 直径0.36m的圆截面
main_cable_materialdata = MaterialData_Cable; % 使用内置的 MaterialData_Cable的材料数据
Sec_cable = Section('主缆Cable',main_cable_sectiondata);
Mat_cable = Material('主缆Cable',main_cable_materialdata);
ET_cable = Link10;

% 主跨主缆：定义对象、找形
CoordA_cable1 = [0,0,0]; % 左端点坐标
CoordB_cable1 = [690,10,50]; % 右端点坐标
L = 7.5+zeros(1,92); % 主缆X向分段，长度n=92
index_hanger = logical([zeros(1,24),repmat([1,0],1,22),zeros(1,23)]);% 吊杆会在主缆哪些位置悬吊，长度n-1=91，X正方向排列，与Cable.ForcePoint方向相同

weight = 5.9627e+08;
count_hanger = 22;
offset = [0,15,-110];
P_z = -weight/count_hanger/4; % 主跨加劲梁girder1的总重被主跨的StayedCable平分
P_h_z = P_z + zeros(1,count_hanger) + 0.1*P_z*rand(1,count_hanger); % 初始吊杆力（吊杆和斜拉索竖向力平分加劲梁自重）
P_h_y = zeros(size(P_h_z));
P_h_x = zeros(size(P_h_z));

Z_Om = -100; % 主缆跨中点Z
obj.Params.P_girder_z_MainSpan = P_h_z;

[cable1,Output_MS] = obj.buildMainSpanCable(CoordA_cable1,CoordB_cable1,L,index_hanger,P_h_x,P_h_y,P_h_z,Z_Om,Sec_cable,Mat_cable,ET_cable);

maincable = obj.StructureList{1};
%}

% 定义荷载
cable_hanger_points = maincable.Point(index_hanger);
cable_hanger_points = cable_hanger_points.sort('X');
force_cable_hanger_Y  = ConcentratedForce(cable_hanger_points,"Y",P_h_y);
force_cable_hanger_Z  = ConcentratedForce(cable_hanger_points,"Z",P_h_z);
obj.addLoad(force_cable_hanger_Y,'Name','吊索作用力Y')
obj.addLoad(force_cable_hanger_Z,'Name','吊索作用力Z')

% 定义约束
support_DoF = {'Ux','Uy','Uz'};
constraint1 = obj.addConstraint(maincable.PointA,support_DoF,zeros(1,length(support_DoF)),'Name','A点约束');
constraint2 = obj.addConstraint(maincable.PointB,support_DoF,zeros(1,length(support_DoF)),'Name','B点约束');

% obj.plot


%
obj.OutputMethod = OutputToAnsys(obj,"AnsysPath","C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe", ...
                                     "JobName","OnlyCable", ...
                                     "MacFilePath","C:\Users\11440\Desktop\usage\Susp V.4\CableSSB-zh\Output Files\main.mac", ...
                                     "ResultFilePath","C:\Users\11440\Desktop\usage\Susp V.4\CableSSB-zh\Output Files\result.out", ...
                                     "WorkPath","C:\Users\11440\Desktop\usage\Susp V.4\CableSSB-zh\Output Files");
% obj.output

%{
inputmethod = InputFromTXT("C:\Users\11440\Desktop\usage\Susp V.4\CableSSB-zh\Output Files\Strain.txt")
inputmethod.action(92)
ansys_stress = inputmethod.RawData;
matlab_stress = maincable.Strain .* maincable.Material.MaterialData.E;
relative_err = (ansys_stress-matlab_stress) ./ matlab_stress *100 % 百分比表示
%}
x = cable1.Result_ShapeFinding.x;