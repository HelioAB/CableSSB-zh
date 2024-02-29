function [obj,f] = SuspensionBridge_span(Z_Om)
    obj = Suspension_Bridge;
    % f: 矢高
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
    
    Point_Hanger_girder1 = girder1.findPoint('Interval','X','ascend',[15+zeros(1,45)]).sort('X'); % 'ascend'时按X正方向距离PointA的距离，寻找girder1的点。这些点是吊索作用点

    % 边跨1加劲梁
    L = 7.5+zeros(1,21);
    CoordA_girder2 = [-0.3,0,-4.2];
    CoordB_girder2 = CoordA_girder1;
    girder2 = obj.buildGirder(CoordA_girder2,CoordB_girder2,L,Sec_girder,Mat_girder,ET_girder);
    
    Point_Hanger_girder2 = girder2.findPoint('Interval','X','descend',[15+zeros(1,9)]).sort('X');
    
    % 边跨2加劲梁
    L = 7.5+zeros(1,21);
    CoordA_girder3 = CoordB_girder1;
    CoordB_girder3 = [1004.7,0,-4.2];
    girder3 = obj.buildGirder(CoordA_girder3,CoordB_girder3,L,Sec_girder,Mat_girder,ET_girder);
    
    Point_Hanger_girder3 = girder3.findPoint('Interval','X','ascend',[15+zeros(1,9)]).sort('X'); 
    
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
    Point_MainCable_tower1 = tower1.findPoint("Index","Z","descend",2).sort('Z'); % 主缆索鞍点
    
    % 桥塔2
    Coord_MoveTo_tower2 = [847.2,0,-87];
    tower2 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower2,Sec_tower,Mat_tower,ET_tower);
    Point_MainCable_tower2 = tower2.findPoint("Index","Z","descend",2).sort('Z');
    
   
    %% 刚臂
    % 定义：截面、材料、单元类型材料
    rigid_beam_sectiondata = RectangleSection(5,5);
    rigid_beam_materialdata = MaterialData_RigidBeam;
    Sec_rigidbeam = Section('刚臂Rigid Beam',rigid_beam_sectiondata);
    Mat_rigidbeam = Material('刚臂Rigid Beam',rigid_beam_materialdata);
    ET_rigidbeam = Beam188;
    
    % girder1 与 Hanger 之间的RigidBeam
    offset1 = [0,14.25,4.2];
    offset2 = [0,-14.25,4.2];
    rigidbeam_1 = obj.buildRigidBeamByOffset(Point_Hanger_girder1,girder1,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_2 = obj.buildRigidBeamByOffset(Point_Hanger_girder1,girder1,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);

    % girder2 与 Hanger 之间的RigidBeam
    rigidbeam_3 = obj.buildRigidBeamByOffset(Point_Hanger_girder2,girder2,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_4 = obj.buildRigidBeamByOffset(Point_Hanger_girder2,girder2,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);

    % girder3 与 Hanger 之间的RigidBeam
    rigidbeam_5 = obj.buildRigidBeamByOffset(Point_Hanger_girder3,girder3,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_6 = obj.buildRigidBeamByOffset(Point_Hanger_girder3,girder3,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    
    % 所有RigidBeam在建立时，给自己和被连接的Structure对象添加Connect Point,详情在rigidbeam.ConnectPoint_Table
    % 关于自己的ConnectPoint留出来做接口，用以连接还未建立的StayedCable和Hanger
    % 通过rigidbeam.ConnectPoint()，引用自身留出来的接口
    % 通过rigidbeam.ConnectPoint(ConnectStructureObj)，引用与该Structure对象相关的ConnectPoint
    
    %% Cable
    % 定义：截面、材料、单元类型材料
    main_cable_sectiondata = CircleSection(0.36/2); % 直径0.36m的圆截面
    main_cable_materialdata = MaterialData_Cable; % 使用内置的 MaterialData_Cable的材料数据
    Sec_cable = Section('主缆Cable',main_cable_sectiondata);
    Mat_cable = Material('主缆Cable',main_cable_materialdata);
    ET_cable = Link10;
    
    % 主跨主缆
    CoordA_cable1 = Point_MainCable_tower1.Coord; % 左端点坐标
    CoordB_cable1 = Point_MainCable_tower2.Coord; % 右端点坐标
    L = 7.5+zeros(1,92); % 主缆X向分段，长度n=92
    index_hanger = logical([0,repmat([1,0],1,45)]);% 吊杆会在主缆哪些位置悬吊，长度n-1=91
    
    girder1_weight = obj.getGirderWeight(girder1);% girder1的重量被主跨吊杆平分
    count_hanger = sum(index_hanger);
    P_z = -girder1_weight/(count_hanger);
    P_h_z_mainspan = P_z+zeros(1,count_hanger); % 初始吊杆力（吊杆和斜拉索竖向力平分加劲梁自重）
    P_h_y = -P_h_z_mainspan*abs((CoordA_cable1(2)-offset1(2))/(CoordA_cable1(3)-offset1(3)));
    P_h_x = zeros(size(P_h_z_mainspan));
    
    f = (CoordA_cable1(3)+CoordB_cable1(3))/2 - Z_Om;
    obj.Params.P_girder_z_MainSpan = P_h_z_mainspan;
    
    [cable1,Output_MS] = obj.buildMainSpanCable(CoordA_cable1,CoordB_cable1,L,index_hanger,P_h_x,P_h_y,P_h_z_mainspan,Z_Om,Sec_cable,Mat_cable,ET_cable);
    cable2 = obj.symmetrizeCable(cable1); 
    
    
    % 边跨1主缆
    CoordA_cable2 = [-7.8,16,-4.2];
    CoordB_cable2 = CoordA_cable1;
    L = 7.5+zeros(1,22);
    index_hanger = logical([0,0,0,repmat([1,0],1,9)]); % 按X正方向设置true
    F_x = Output_MS.F_x;

    girder2_weight = obj.getGirderWeight(girder2);% girder1的重量被主跨吊杆平分
    count_hanger = sum(index_hanger);
    P_z = -girder2_weight/(count_hanger);
    P_h_z_sidespan1 = P_z+zeros(1,count_hanger); % 初始吊杆力（吊杆和斜拉索竖向力平分加劲梁自重）
    P_h_y = -P_h_z_sidespan1*abs((CoordA_cable1(2)-offset1(2))/(CoordA_cable1(3)-offset1(3)));
    P_h_x = zeros(size(P_h_z_sidespan1));

    cable3 = obj.buildSideSpanCable(CoordA_cable2,CoordB_cable2,L,index_hanger,P_h_x,P_h_y,P_h_z_sidespan1,F_x,Sec_cable,Mat_cable,ET_cable);
    cable4 = obj.symmetrizeCable(cable3);
    
    % 边跨2主缆
    CoordA_cable3 = CoordB_cable1;
    CoordB_cable3 = [1012.2,16,-4.2];
    L = 7.5+zeros(1,22);
    index_hanger = logical([repmat([0,1],1,9),0,0,0]);
    F_x = Output_MS.F_x;

    girder3_weight = obj.getGirderWeight(girder3);% girder1的重量被主跨吊杆平分
    count_hanger = sum(index_hanger);
    P_z = -girder3_weight/(count_hanger);
    P_h_z_sidespan2 = P_z+zeros(1,count_hanger); % 初始吊杆力（吊杆和斜拉索竖向力平分加劲梁自重）
    P_h_y = -P_h_z_sidespan2*abs((CoordA_cable1(2)-offset1(2))/(CoordA_cable1(3)-offset1(3)));
    P_h_x = zeros(size(P_h_z_sidespan2));
    
    cable5 = obj.buildSideSpanCable(CoordA_cable3,CoordB_cable3,L,index_hanger,P_h_x,P_h_y,P_h_z_sidespan2,F_x,Sec_cable,Mat_cable,ET_cable);
    cable6 = obj.symmetrizeCable(cable5);
    
    %% Hanger
    % 定义：截面、材料、单元类型材料
    hanger_sectiondata = CircleSection(0.0731/2);
    hanger_materialdata = MaterialData_Q345;
    Sec_hanger = Section('吊杆Hanger',hanger_sectiondata);
    Mat_hanger = Material('吊杆Hanger',hanger_materialdata);
    ET_hanger = Link10;
    
    hanger_1 = obj.buildHanger(rigidbeam_1.ConnectPoint,cable1.ConnectPoint,rigidbeam_1,cable1,Sec_hanger,Mat_hanger,ET_hanger);
    hanger_2 = obj.buildHanger(rigidbeam_2.ConnectPoint,cable2.ConnectPoint,rigidbeam_2,cable2,Sec_hanger,Mat_hanger,ET_hanger);

    hanger_3 = obj.buildHanger(rigidbeam_3.ConnectPoint,cable3.ConnectPoint,rigidbeam_3,cable3,Sec_hanger,Mat_hanger,ET_hanger);
    hanger_4 = obj.buildHanger(rigidbeam_4.ConnectPoint,cable4.ConnectPoint,rigidbeam_4,cable4,Sec_hanger,Mat_hanger,ET_hanger);
    
    hanger_5 = obj.buildHanger(rigidbeam_5.ConnectPoint,cable5.ConnectPoint,rigidbeam_5,cable5,Sec_hanger,Mat_hanger,ET_hanger);
    hanger_6 = obj.buildHanger(rigidbeam_6.ConnectPoint,cable6.ConnectPoint,rigidbeam_6,cable6,Sec_hanger,Mat_hanger,ET_hanger);
    
    %% 赋予斜拉索和吊杆初始力
    hanger_list = {hanger_1,hanger_2,hanger_3,hanger_4,hanger_5,hanger_6};% 必须是Hanger对象或StayedCable对象构成的cell
    force_list = {P_h_z_mainspan,P_h_z_mainspan,P_h_z_sidespan1,P_h_z_sidespan1,P_h_z_sidespan2,P_h_z_sidespan2}; % 必须和第1和参数的向量长度保持一致
    obj.setForceTo(hanger_list,force_list);
    
    %% 耦合 Coupling

    % 自锚耦合
    anchor1_masterpoint = anchor1.findPoint('Index','X','descend',2);
    anchor2_masterpoint = anchor2.findPoint('Index','X','descend',2);
    CP_selfanchor_1 = obj.addCoupling(anchor1_masterpoint,[cable3.PointA,cable4.PointA],{'Ux','Uy','Uz'},'Name','自锚耦合1','isCableRelated',true);% 与缆索有关
    CP_selfanchor_2 = obj.addCoupling(anchor2_masterpoint,[cable5.PointB,cable6.PointB],{'Ux','Uy','Uz'},'Name','自锚耦合2','isCableRelated',true);

    % Tower和Girder之间的耦合
    tower1_masterpoint = tower1.Point.findPointByRange([],0,-19.15);
    tower2_masterpoint = tower2.Point.findPointByRange([],0,-19.15);
    CP_tower1_girder = obj.addCoupling(tower1_masterpoint,girder1.PointA,{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合1','isCableRelated',false);% 与缆索无关
    CP_tower2_girder = obj.addCoupling(tower2_masterpoint,girder1.PointB,{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合2','isCableRelated',false);

   
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

    folder = ['S:\03 软著\何力 软著书写\图\Suspension_Bridge'];
    obj.OutputMethod.WorkPath = folder;
    obj.OutputMethod.JobName = 'Suspension_Bridge';
    obj.OutputMethod.MacFilePath = [folder,'\main.mac'];
    obj.OutputMethod.ResultFilePath = [folder,'\result.out'];
end