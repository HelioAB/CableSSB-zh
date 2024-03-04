function obj = HybridBirgde_NonCableSystem()
    obj = CableStayedSuspension_Bridge;
    %% 加劲梁与锚碇
    % 单位：N, m
    % 方向：X：顺桥向；Y：横桥向；Z:竖向。XYZ坐标系满足右手系
    % 定义：截面、材料、单元类型
    girder_sectiondata = UserSection(5.3482,20,190.1827,193,36,8); % 定义截面数据，UserSection是用户自定义截面数据，User(A,Ixx,Iyy,Izz,TKy,TKz) ，单位: m
    girder_materialdata = MaterialData_Q345; % 定义材料属性，MaterialData_Q345为内置的Q345钢的材料属性，单位: N, m
    Sec_girder = Section('主梁Girder',girder_sectiondata); % 定义截面，后面在定义后面的结构时，使用这里定义的Sec_girder。这里的截面名称'主梁Girder'会出现在Ansys宏文件的注释中，方便检查
    Mat_girder = Material('主梁Girder',girder_materialdata); % 定义材料，后面在定义后面的结构时，使用这里定义的Mat_girder。
    ET_girder = Beam188; % 单元类型选择为Ansys中的Beam188单元。
    
    % 主跨加劲梁
    L = 7.5*ones(1,92); % 该段加劲梁的分段情况，只需要输入每一段的正确比例就可以
    CoordA_girder1 = [157.2,0,-4.2]; % 加劲梁左端点A的位置，"左"代表 X向数值更小的方向。
    CoordB_girder1 = [847.2,0,-4.2]; % 加劲梁右端点B的位置
    girder1 = obj.buildGirder(CoordA_girder1,CoordB_girder1,L,Sec_girder,Mat_girder,ET_girder); % 根据比例L，对CoordA和CoordB线性插值
   
    
    % 边跨1加劲梁
    L = 7.5+zeros(1,21);
    CoordA_girder2 = [-0.3,0,-4.2];
    CoordB_girder2 = CoordA_girder1;
    girder2 = obj.buildGirder(CoordA_girder2,CoordB_girder2,L,Sec_girder,Mat_girder,ET_girder);
    
    Point_Hanger_girder2 = girder2.findPoint('Interval','X','ascend',[]).sort('X');
    Point_StayedCable_girder2 = girder2.findPoint('Interval','X','descend',[30,15+zeros(1,4),7.5+zeros(1,9)]).sort('X');
    
    % 边跨2加劲梁
    L = 7.5+zeros(1,21);
    CoordA_girder3 = CoordB_girder1;
    CoordB_girder3 = [1004.7,0,-4.2];
    girder3 = obj.buildGirder(CoordA_girder3,CoordB_girder3,L,Sec_girder,Mat_girder,ET_girder);
    
    Point_Hanger_girder3 = girder3.findPoint('Interval','X','ascend',[]).sort('X'); 
    Point_StayedCable_girder3 = girder3.findPoint('Interval','X','ascend',[30,15+zeros(1,4),7.5+zeros(1,9)]).sort('X');
    
    %% 自锚锚碇
    % 定义：截面、材料、单元类型
    anchor_sectiondata = UserSection(20.3482,200,1900.1827,1930.,36,8);
    anchor_materialdata = MaterialData_C60;
    Sec_anchor = Section('锚碇Girder',anchor_sectiondata);
    Mat_anchor = Material('锚碇Girder',anchor_materialdata);
    ET_anchor = Beam188;
    
    % 边跨1锚碇
    L = [20,7.5];
    CoordA_anchor1 = [-27.8,0,-4.2];
    CoordB_anchor1 = CoordA_girder2;
    anchor1 = obj.buildGirder(CoordA_anchor1,CoordB_anchor1,L,Sec_anchor,Mat_anchor,ET_anchor);
    
    % 边跨2锚碇
    L = [7.5,20];
    CoordA_anchor2 = CoordB_girder3;
    CoordB_anchor2 = [1032.2,0,-4.2];
    anchor2 = obj.buildGirder(CoordA_anchor2,CoordB_anchor2,L,Sec_anchor,Mat_anchor,ET_anchor);
    
    % 将加劲梁和锚碇在交点处融合在一起
    girder = [anchor1,girder2,girder1,girder3,anchor2];% 这个对象数组的前后顺序就是X方向的顺序。
    girder.merge;
    
    %% 桥塔
    % 定义：截面、材料、单元类型
    tower_sectiondata = BoxSection(7,7,1,1,1,1);
    tower_materialdata = MaterialData_C60;
    Sec_tower = Section('桥塔Tower',tower_sectiondata);
    Mat_tower = Material('桥塔Tower',tower_materialdata);
    ET_tower = Beam188;
    
    % 从CAD中导入桥塔的线模型
    model_path_tower = 'Example-Tower.txt';
    Method_Creating = InputFromAutoCAD(model_path_tower);
    
    % 桥塔1
    fun_handle = @(tower) tower.findPoint('Index','Z','ascend',1);% 寻找参考点的方法，输入tower对象，输出参考点
    Coord_MoveTo_tower1 = [157.2,0,-87];% 塔根位置
    tower1 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower1,Sec_tower,Mat_tower,ET_tower);
    Point_MainCable_tower1 = tower1.findPoint("Index","Z","descend",2).sort('Z'); % 主缆索鞍点,按Z正方向排列
    Point_StayedCable_tower1 = tower1.findPoint("Index","Z","descend",3:16).sort('Z'); % 斜拉索锚固位置（还要经过刚臂转化到斜拉索上）
    
    % 桥塔2
    Coord_MoveTo_tower2 = [847.2,0,-87];
    tower2 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower2,Sec_tower,Mat_tower,ET_tower);
    Point_MainCable_tower2 = tower2.findPoint("Index","Z","descend",2).sort('Z');
    Point_StayedCable_tower2 = tower2.findPoint("Index","Z","descend",3:16).sort('Z');
    
    %% 辅助墩
    % 定义：截面、材料、单元类型
    pier_sectiondata = BoxSection(7,7,1,1,1,1);
    pier_materialdata = MaterialData_C60;
    Sec_pier = Section('辅助墩Pier',pier_sectiondata);
    Mat_pier = Material('辅助墩Pier',pier_materialdata);
    ET_pier = Beam188;
    
    % 从CAD中导入桥塔的线模型
    model_path_pier = 'Example-Pier.txt';
    Method_Creating = InputFromAutoCAD(model_path_pier);
    
    % 辅助墩1
    fun_handle = @(pier) pier.findPoint('Index','Z','ascend',1);
    Coord_MoveTo_pier1 = [67.2,0,-57.4];% 辅助墩墩底位置
    pier1 = obj.buildPierByInput(Method_Creating,fun_handle,Coord_MoveTo_pier1,Sec_pier,Mat_pier,ET_pier);
    Point_Top_pier1 = pier1.findPoint("Index","Z","descend",2); % 辅助墩横梁中点处
    
    % 辅助墩2
    Coord_MoveTo_pier2 = [937.2,0,-57.4];
    pier2 = obj.buildPierByInput(Method_Creating,fun_handle,Coord_MoveTo_pier2,Sec_pier,Mat_pier,ET_pier);
    Point_Top_pier2 = pier2.findPoint("Index","Z","descend",2);

  
    %% 耦合 Coupling

    % Tower和Girder之间的耦合
    tower1_masterpoint = tower1.Point.findPointByRange([],0,-19.15);
    tower2_masterpoint = tower2.Point.findPointByRange([],0,-19.15);
    CP_tower1_girder = obj.addCoupling(tower1_masterpoint,girder1.PointA,{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合1','isCableRelated',false);% 与缆索无关
    CP_tower2_girder = obj.addCoupling(tower2_masterpoint,girder1.PointB,{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合2','isCableRelated',false);

    % 辅助墩墩顶耦合
    girder2_salvepoint = girder2.Point.findPointByRange(Coord_MoveTo_pier1(1),[],[]);
    girder3_slavepoint = girder3.Point.findPointByRange(Coord_MoveTo_pier2(1),[],[]);
    CP_pier1_girder = obj.addCoupling(Point_Top_pier1,girder2_salvepoint,{'Uz'},'Name','辅助墩、梁耦合1','isPierRelated',true);% 与Pier无关
    CP_pier2_girder = obj.addCoupling(Point_Top_pier2,girder3_slavepoint,{'Uz'},'Name','辅助墩、梁耦合2','isPierRelated',true);

    %% 约束 Constraint
    
    % 塔底约束
    all_DoF = DoF.All.Name; % {'Ux','Uy','Uz','Rotx','Roty','Rotz'}
    constraint1 = obj.addConstraint(tower1.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','塔底固结1','isCableRelated',false);% 与缆索无关
    constraint2 = obj.addConstraint(tower2.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','塔底固结2','isCableRelated',false);
    
    % 梁端约束
    support_DoF_1 = {'Ux','Uy','Uz','Rotx'};
    support_DoF_2 = {'Ux','Uy','Uz','Rotx'};
    constraint3 = obj.addConstraint(anchor1.PointA,support_DoF_1,zeros(1,length(support_DoF_1)),'Name','梁端约束1','isCableRelated',false);% 与缆索无关
    constraint4 = obj.addConstraint(anchor2.PointB,support_DoF_2,zeros(1,length(support_DoF_2)),'Name','梁端约束2','isCableRelated',false);
    
    % 辅助墩墩底约束
    constraint5 = obj.addConstraint(pier1.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','辅助墩固结1','isPierRelated',true);% 与缆索无关
    constraint6 = obj.addConstraint(pier2.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','辅助墩固结2','isPierRelated',true);
    % 主缆地锚固结
    %             support_DoF_5 = {'Ux','Uy','Uz'};
    %             support_DoF_6 = {'Ux','Uy','Uz'};
    %             support_DoF_7 = {'Ux','Uy','Uz'};
    %             support_DoF_8 = {'Ux','Uy','Uz'};
    %             constraint5 = obj.addConstraint(cable3.PointA,support_DoF_5,zeros(1,length(support_DoF_5)),'Name','地锚固结1');
    %             constraint6 = obj.addConstraint(cable4.PointA,support_DoF_6,zeros(1,length(support_DoF_6)),'Name','地锚固结2');
    %             constraint7 = obj.addConstraint(cable5.PointB,support_DoF_7,zeros(1,length(support_DoF_7)),'Name','地锚固结3');
    %             constraint8 = obj.addConstraint(cable6.PointB,support_DoF_8,zeros(1,length(support_DoF_8)),'Name','地锚固结4');
    
        
    %% 荷载 Load
    
    % % 选择作用位置，中跨右半跨
    % XSorted_girder1_line = girder1.findLineByCenterCoord('X','ascend');
    % half_len = floor(length(XSorted_girder1_line)/2);
    % HalfSpanLoad_girder1_line = XSorted_girder1_line(1:half_len);
    % 
    % HalfSpanLoad = UniformLoad(HalfSpanLoad_girder1_line,"Z",-100);
    % obj.addLoad(HalfSpanLoad,'Name','主跨 左半跨荷载');
    % 
    % % 边跨满跨荷载
    % FullSpanLoad_girder2_line = girder2.findLineByCenterCoord('X','ascend');
    % FullSpanLoad = UniformLoad(FullSpanLoad_girder2_line,'Z',-120);
    % obj.addLoad(FullSpanLoad,'Name','边跨1 满跨荷载');
    % 
    % % 跨中集中荷载
    % girder1_XPoint = girder1.Point.sort('X');
    % girder1_MidspanPoint = girder1_XPoint([round(length(girder1_XPoint)/2),round(length(girder1_XPoint)/2)+1]);
    % MidSpanLoad_Y  = ConcentratedForce(girder1_MidspanPoint,"Y",[100,200]);
    % obj.addLoad(MidSpanLoad_Y,'Name','中跨跨中Y向集中荷载')
    
    %% 设置输出方式
    obj.OutputMethod = OutputToAnsys(obj);

    folder = ['C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Chapter02\Result\NonCableSystem'];
    obj.OutputMethod.WorkPath = folder;
    obj.OutputMethod.JobName = 'NonCableSystem';
    obj.OutputMethod.MacFilePath = [folder,'\main.mac'];
    obj.OutputMethod.ResultFilePath = [folder,'\result.out'];
    
end