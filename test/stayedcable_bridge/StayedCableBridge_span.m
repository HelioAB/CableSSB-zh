function obj = StayedCableBridge_span(span_main)
    obj = CableStayed_Bridge;
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
%     span_main = 70*7.5;
    length_seg = span_main/70; % 5+28+4+28+5 

    L = length_seg*ones(1,70); % 该段加劲梁的分段情况，只需要输入每一段的正确比例就可以
    CoordA_girder1 = [0,0,-4.2]; % 加劲梁左端点A的位置，"左"代表 X向数值更小的方向。
    CoordB_girder1 = [span_main,0,-4.2]; % 加劲梁右端点B的位置
    girder1 = obj.buildGirder(CoordA_girder1,CoordB_girder1,L,Sec_girder,Mat_girder,ET_girder); % 根据比例L，对CoordA和CoordB线性插值
    
    Point_StayedCable_girder1_1 = girder1.findPoint('Interval','X','ascend',[length_seg*5,length_seg*2+zeros(1,14)]).sort('X'); % 这些点是靠近PointA的斜拉索作用点
    Point_StayedCable_girder1_2 = girder1.findPoint('Interval','X','descend',[length_seg*5,length_seg*2+zeros(1,14)]).sort('X'); % 这些点是靠近PointB的斜拉索作用点
    
    % 边跨1加劲梁
    L = 7.5+zeros(1,22);
    CoordB_girder2 = CoordA_girder1;
    CoordA_girder2 = [CoordA_girder1(1)-sum(L),0,-4.2];
    girder2 = obj.buildGirder(CoordA_girder2,CoordB_girder2,L,Sec_girder,Mat_girder,ET_girder);
    
    Point_StayedCable_girder2 = girder2.findPoint('Interval','X','descend',[30,15+zeros(1,4),7.5+zeros(1,10)]).sort('X');
    
    % 边跨2加劲梁
    
    L = 7.5+zeros(1,22);
    CoordA_girder3 = CoordB_girder1;
    CoordB_girder3 = [CoordB_girder1(1)+sum(L),0,-4.2];
    girder3 = obj.buildGirder(CoordA_girder3,CoordB_girder3,L,Sec_girder,Mat_girder,ET_girder);
    
    Point_StayedCable_girder3 = girder3.findPoint('Interval','X','ascend',[30,15+zeros(1,4),7.5+zeros(1,10)]).sort('X');
    
    %% 锚碇
    % 定义：截面、材料、单元类型
    anchor_sectiondata = UserSection(20.3482,200,1900.1827,1930.,36,8);
    anchor_materialdata = MaterialData_C60;
    Sec_anchor = Section('锚碇Girder',anchor_sectiondata);
    Mat_anchor = Material('锚碇Girder',anchor_materialdata);
    ET_anchor = Beam188;
    
    % 边跨1锚碇
    L = 20;
    CoordB_anchor1 = CoordA_girder2;
    CoordA_anchor1 = [CoordA_girder2(1)-L,0,-4.2];
    anchor1 = obj.buildGirder(CoordA_anchor1,CoordB_anchor1,L,Sec_anchor,Mat_anchor,ET_anchor);
    
    % 边跨2锚碇
    L = 20;
    CoordA_anchor2 = CoordB_girder3;
    CoordB_anchor2 = [CoordB_girder3(1)+L,0,-4.2];
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
    Coord_MoveTo_tower1 = [CoordA_girder1(1),0,-87];% 塔根位置
    tower1 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower1,Sec_tower,Mat_tower,ET_tower);
    Point_StayedCable_tower1 = tower1.findPoint("Index","Z","descend",2:16).sort('Z'); % 斜拉索锚固位置（还要经过刚臂转化到斜拉索上）
    
    % 桥塔2
    Coord_MoveTo_tower2 = [CoordB_girder1(1),0,-87];
    tower2 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower2,Sec_tower,Mat_tower,ET_tower);
    Point_StayedCable_tower2 = tower2.findPoint("Index","Z","descend",2:16).sort('Z');
    
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
    Coord_MoveTo_pier1 = [CoordA_girder1(1)-90,0,-57.4];% 辅助墩墩底位置
    pier1 = obj.buildPierByInput(Method_Creating,fun_handle,Coord_MoveTo_pier1,Sec_pier,Mat_pier,ET_pier);
    Point_Top_pier1 = pier1.findPoint("Index","Z","descend",2); % 辅助墩横梁中点处
    
    % 辅助墩2
    Coord_MoveTo_pier2 = [CoordB_girder1(1)+90,0,-57.4];
    pier2 = obj.buildPierByInput(Method_Creating,fun_handle,Coord_MoveTo_pier2,Sec_pier,Mat_pier,ET_pier);
    Point_Top_pier2 = pier2.findPoint("Index","Z","descend",2);

    %% 刚臂
    % 定义：截面、材料、单元类型材料
    rigid_beam_sectiondata = RectangleSection(5,5);
    rigid_beam_materialdata = MaterialData_RigidBeam;
    Sec_rigidbeam = Section('刚臂Rigid Beam',rigid_beam_sectiondata);
    Mat_rigidbeam = Material('刚臂Rigid Beam',rigid_beam_materialdata);
    ET_rigidbeam = Beam188;
    
    % girder1 与 StayedCable 之间的RigidBeam
    offset1 = [0,14.25,4.2];
    offset2 = [0,-14.25,4.2];
    rigidbeam_1 = obj.buildRigidBeamByOffset(Point_StayedCable_girder1_1,girder1,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_2 = obj.buildRigidBeamByOffset(Point_StayedCable_girder1_1,girder1,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_3 = obj.buildRigidBeamByOffset(Point_StayedCable_girder1_2,girder1,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_4 = obj.buildRigidBeamByOffset(Point_StayedCable_girder1_2,girder1,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    % girder2 与 StayedCable 之间的RigidBeam
    rigidbeam_5 = obj.buildRigidBeamByOffset(Point_StayedCable_girder2,girder2,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_6 = obj.buildRigidBeamByOffset(Point_StayedCable_girder2,girder2,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    % girder3 与 StayedCable 之间的RigidBeam
    rigidbeam_7 = obj.buildRigidBeamByOffset(Point_StayedCable_girder3,girder3,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_8 = obj.buildRigidBeamByOffset(Point_StayedCable_girder3,girder3,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    % tower1 与 StayedCable 之间的RigidBeam
    offset3 = [0,2.44,0];
    offset4 = [0,-2.44,0];
    rigidbeam_9 = obj.buildRigidBeamByOffset(Point_StayedCable_tower1,tower1,offset3,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_10 = obj.buildRigidBeamByOffset(Point_StayedCable_tower1,tower1,offset4,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    % tower2 与 StayedCable 之间的RigidBeam
    rigidbeam_11 = obj.buildRigidBeamByOffset(Point_StayedCable_tower2,tower2,offset3,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_12 = obj.buildRigidBeamByOffset(Point_StayedCable_tower2,tower2,offset4,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    
    % 所有RigidBeam在建立时，给自己和被连接的Structure对象添加Connect Point,详情在rigidbeam.ConnectPoint_Table
    % 关于自己的ConnectPoint留出来做接口，用以连接还未建立的StayedCable和Hanger
    % 通过rigidbeam.ConnectPoint()，引用自身留出来的接口
    % 通过rigidbeam.ConnectPoint(ConnectStructureObj)，引用与该Structure对象相关的ConnectPoint
    
    %% StayedCable
    stayedcable_sectiondata = CircleSection(0.1178/2);
    stayedcable_materialdata = MaterialData_Cable;
    Sec_stayedcable = Section('斜拉索Stayed',stayedcable_sectiondata);
    Mat_stayedcable = Material('斜拉索Stayeed',stayedcable_materialdata);
    ET_stayedcable = Link10;
    
    % girder1 与 tower1 之间的 StayedCable
    stayedcable_1 = obj.buildStayedCable(rigidbeam_1.ConnectPoint,rigidbeam_9.ConnectPoint,rigidbeam_1,rigidbeam_9,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_2 = obj.buildStayedCable(rigidbeam_2.ConnectPoint,rigidbeam_10.ConnectPoint,rigidbeam_2,rigidbeam_10,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    % girder1 与 tower2 之间的 StayedCable
    stayedcable_3 = obj.buildStayedCable(rigidbeam_3.ConnectPoint,rigidbeam_11.ConnectPoint.reverse,rigidbeam_3,rigidbeam_11,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_4 = obj.buildStayedCable(rigidbeam_4.ConnectPoint,rigidbeam_12.ConnectPoint.reverse,rigidbeam_4,rigidbeam_12,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    % girder2 与 tower1 之间的 StayedCable
    stayedcable_5 = obj.buildStayedCable(rigidbeam_5.ConnectPoint,rigidbeam_9.ConnectPoint.reverse,rigidbeam_5,rigidbeam_9,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_6 = obj.buildStayedCable(rigidbeam_6.ConnectPoint,rigidbeam_10.ConnectPoint.reverse,rigidbeam_6,rigidbeam_10,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    % girder3 与 tower2 之间的 StayedCable
    stayedcable_7 = obj.buildStayedCable(rigidbeam_7.ConnectPoint,rigidbeam_11.ConnectPoint,rigidbeam_7,rigidbeam_11,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_8 = obj.buildStayedCable(rigidbeam_8.ConnectPoint,rigidbeam_12.ConnectPoint,rigidbeam_8,rigidbeam_12,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    
    %% 赋予斜拉索和吊杆初始力
    stayedcable_list = obj.findStructureByClass('StayedCable');
    girder_weight = obj.getGirderWeight();% 若该方法不输入参数，则代表全桥加劲梁总重
    P_z = girder_weight/length(stayedcable_list);% 全加劲梁总重被StayedCable平分
    obj.setForceTo(stayedcable_list,P_z+zeros(1,length(stayedcable_list)))

    %% 耦合 Coupling

    % Tower和Girder之间的耦合
    tower1_masterpoint = tower1.Point.findPointByRange([],0,-19.15);
    tower2_masterpoint = tower2.Point.findPointByRange([],0,-19.15);
    CP_tower1_girder = obj.addCoupling(tower1_masterpoint,girder1.PointA,{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合1','isCableRelated',false);% 与缆索无关
    CP_tower2_girder = obj.addCoupling(tower2_masterpoint,girder1.PointB,{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合2','isCableRelated',false);

    % 辅助墩墩顶耦合
    girder2_slavepoint = girder2.Point.findPointByRange(Coord_MoveTo_pier1(1),[],[]);
    girder3_slavepoint = girder3.Point.findPointByRange(Coord_MoveTo_pier2(1),[],[]);
    CP_pier1_girder = obj.addCoupling(Point_Top_pier1,girder2_slavepoint,{'Ux','Uy','Uz','Rotx'},'Name','辅助墩、梁耦合1','isPierRelated',true);% 与Pier相关
    CP_pier2_girder = obj.addCoupling(Point_Top_pier2,girder3_slavepoint,{'Ux','Uy','Uz','Rotx'},'Name','辅助墩、梁耦合2','isPierRelated',true);

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
    constraint5 = obj.addConstraint(pier1.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','辅助墩固结1','isPierRelated',false);% 与Pier相关
    constraint6 = obj.addConstraint(pier2.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','辅助墩固结2','isPierRelated',false);
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
    % 边跨满跨荷载
    FullSpanLoad_girder2_line = girder2.findLineByCenterCoord('X','ascend');
    FullSpanLoad = UniformLoad(FullSpanLoad_girder2_line,'Z',-6000000);
    obj.addLoad(FullSpanLoad,'Name','边跨1 满跨荷载');
    % 
    % % 跨中集中荷载
    % girder1_XPoint = girder1.Point.sort('X');
    % girder1_MidspanPoint = girder1_XPoint([round(length(girder1_XPoint)/2),round(length(girder1_XPoint)/2)+1]);
    % MidSpanLoad_Y  = ConcentratedForce(girder1_MidspanPoint,"Y",[100,200]);
    % obj.addLoad(MidSpanLoad_Y,'Name','中跨跨中Y向集中荷载')
    
    %% 设置输出方式
    obj.OutputMethod = OutputToAnsys(obj);
    folder = ['S:\03 软著\何力 软著书写\图\CableStayed_Bridge'];
    obj.OutputMethod.WorkPath = folder;
    obj.OutputMethod.JobName = 'CableStayed_Bridge';
    obj.OutputMethod.MacFilePath = [folder,'\main.mac'];
    obj.OutputMethod.ResultFilePath = [folder,'\result.out'];
end