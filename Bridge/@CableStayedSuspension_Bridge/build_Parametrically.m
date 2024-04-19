function build_Parametrically(obj,options)
    arguments
        obj
        options.Ratio_SideMainSpan = 1
        options.Sag = 102.35
        options.Count_CrossCable = 3

        options.Length_HangerSpan = []
        options.Area_MainCable = [] % 这个参数是配合Length_HangerSpan的变化

        options.Count_Pier = []
        
        options.IfGravityRelated_GirderArea = true;% 改变加劲梁面积时，是否同时改变加劲梁重力，true则同时改变重力，false则不改变重力
        % options.GirderArea_StayedCable = []
        % options.GirderArea_Suspension = []
        % options.GirderArea_Combination = []
        options.GirderArea_MainSpan = 6.3676%
        options.GirderArea_SideSpan = 9.0342%
   
        options.GirderStiffness_Bending_StayedCable = []%
        options.GirderStiffness_Bending_Suspension = []%
        options.GirderStiffness_Bending_Combination = []%
        options.GirderStiffness_Bending_MainSpan = 190.1827%
        options.GirderStiffness_Bending_SideSpan = 190.1827%
    end
    disp('Is building a Cable-Stayed Suspension Bridge...')
    %% 参数赋值
    % 边中跨比
    seg_mainspan = 7.5;
    seg_sidespan_1 = options.Ratio_SideMainSpan*seg_mainspan;
    seg_sidespan_2 = options.Ratio_SideMainSpan*seg_mainspan;
    % 垂跨比
    sag = options.Sag;
    % 交叉索数
    count_crosscable = options.Count_CrossCable;
    % 吊跨比
    if ~isempty(options.Length_HangerSpan)
        count_crosscable = 0;% 研究Length_HangerSpan时，交叉索数必须为0
        if ~isempty(options.Area_MainCable)
        else
        end
    end
    % 主缆面积

    % 加劲梁轴向刚度
    if options.IfGravityRelated_GirderArea
        Area_MainSpan_Girder = options.GirderArea_MainSpan;
        Area_SideSpan_Girder = options.GirderArea_SideSpan;
    else
        error('暂时未开发「加劲梁截面面积改变时自重不变」的情况')
    end

    % 加劲梁竖向抗弯刚度
    % 整体、主跨、边跨
    Iyy_MainSpan_Girder = options.GirderStiffness_Bending_MainSpan;
    Iyy_SideSpan_Girder = options.GirderStiffness_Bending_SideSpan;
    % 斜拉部分、悬索部分、结合段
    if isempty(options.GirderStiffness_Bending_StayedCable) && isempty(options.GirderStiffness_Bending_Suspension)
        flag_Iyy_SeperatedSystem = false;
    elseif ~isempty(options.GirderStiffness_Bending_StayedCable) && ~isempty(options.GirderStiffness_Bending_Suspension)
        flag_Iyy_SeperatedSystem = true;
        Iyy_StayedCable_Girder = options.GirderStiffness_Bending_StayedCable;
        Iyy_Suspension_Girder = options.GirderStiffness_Bending_Suspension;
        if isempty(options.GirderStiffness_Bending_Combination)
            Iyy_Combination_Girder = (Iyy_StayedCable_Girder + Iyy_Suspension_Girder)/2;
        else
            Iyy_Combination_Girder = options.GirderStiffness_Bending_Combination;
        end
    else
        error('若要为斜拉部分、悬索部分、结合端的竖向抗弯刚度赋值，则需要为它们同时赋值')
    end

    % 主跨和边跨数量确定
    obj.StructureCell_MainSpan = cell(1,1);
    obj.StructureCell_SideSpan = cell(1,2);

    %% 加劲梁与锚碇
    % 单位：N, m
    % 方向：X：顺桥向；Y：横桥向；Z:竖向。XYZ坐标系满足右手系
    % 定义：截面、材料、单元类型
    ET_girder1 = Beam188; % 单元类型选择为Ansys中的Beam188单元。
    girder1_materialdata = MaterialData_Q345; % 定义材料属性，MaterialData_Q345为内置的Q345钢的材料属性，单位: N, m
    Mat_girder1 = Material('主跨主梁Girder',girder1_materialdata); % 定义材料，后面在定义后面的结构时，使用这里定义的Mat_girder。
    
    % 主跨加劲梁
    L = seg_mainspan*ones(1,92); % 该段加劲梁的分段情况，只需要输入每一段的正确比例就可以
    CoordA_girder1 = [157.2,0,-4.2]; % 加劲梁左端点A的位置，"左"代表 X向数值更小的方向。
    CoordB_girder1 = [CoordA_girder1(1)+sum(L),CoordA_girder1(2),CoordA_girder1(3)]; % 加劲梁右端点B的位置
    if flag_Iyy_SeperatedSystem
        girder1_sectiondata_suspension = UserSection(Area_MainSpan_Girder,20,Iyy_Suspension_Girder,193,36,8);
        girder1_sectiondata_stayedcable = UserSection(Area_MainSpan_Girder,20,Iyy_StayedCable_Girder,193,36,8);
        girder1_sectiondata_combination = UserSection(Area_MainSpan_Girder,20,Iyy_Combination_Girder,193,36,8);
        Sec_gitder1_suspension = Section('主跨主梁Girder-Suspension部分',girder1_sectiondata_suspension);
        Sec_girder1_stayedcable = Section('主跨主梁Girder-StayedCable部分',girder1_sectiondata_stayedcable);
        Sec_girder1_combination = Section('主跨主梁Girder-Combination部分',girder1_sectiondata_combination);

        girder1 = obj.buildGirder(CoordA_girder1,CoordB_girder1,L,Sec_gitder1_suspension,Mat_girder1,ET_girder1); % 根据比例L，对CoordA和CoordB线性插值
        Sec_girder1_stayedcable.record;
        Sec_girder1_combination.record;
    else      
        girder1_sectiondata = UserSection(6.3676,20,Iyy_MainSpan_Girder,193,36,8); % 定义截面数据，UserSection是用户自定义截面数据，User(A,Ixx,Iyy,Izz,TKy,TKz) ，单位: m

        Sec_girder1 = Section('主跨主梁Girder',girder1_sectiondata); % 定义截面
        girder1 = obj.buildGirder(CoordA_girder1,CoordB_girder1,L,Sec_girder1,Mat_girder1,ET_girder1); % 根据比例L，对CoordA和CoordB线性插值
    end
    obj.addToSpan('MainSpan',1,girder1);
    
    Point_Hanger_girder1 = girder1.findPoint('Interval','X','ascend',[(31-2*count_crosscable)*seg_mainspan,2*seg_mainspan+zeros(1,15+2*count_crosscable)]); % 'ascend'时按X正方向距离PointA的距离，寻找girder1的点。这些点是吊索作用点
    Point_Hanger_girder1 = Point_Hanger_girder1.sort('X');% 按X正方向的顺序排列
    index_Hanger_girder1 = girder1.findPointIndex(Point_Hanger_girder1);

    Point_StayedCable1_girder1 = girder1.findPoint('Interval','X','ascend',[4*seg_mainspan,2*seg_mainspan+zeros(1,13)]); % 这些点是靠近PointA的斜拉索作用点
    Point_StayedCable2_girder1 = girder1.findPoint('Interval','X','descend',[4*seg_mainspan,2*seg_mainspan+zeros(1,13)]); % 这些点是靠近PointB的斜拉索作用点
    Point_StayedCable1_girder1  = Point_StayedCable1_girder1.sort('X');
    Point_StayedCable2_girder1 = Point_StayedCable2_girder1.sort('X');
    Point_StayedCable_girder1 = [Point_StayedCable1_girder1,Point_StayedCable2_girder1];
    index_StayedCable_girder1 = girder1.findPointIndex(Point_StayedCable_girder1);
    
    [index_Hanger_lines,index_StayedCable1_lines,index_StayedCable2_lines,index_Combination_lines,index_Other_lines] = findMainSpanDivisionIndex(girder1,Point_Hanger_girder1,Point_StayedCable1_girder1,Point_StayedCable2_girder1);
    if flag_Iyy_SeperatedSystem
        girder1.Section(index_Hanger_lines) = Sec_gitder1_suspension;
        girder1.Section(index_StayedCable1_lines) = Sec_girder1_stayedcable;
        girder1.Section(index_StayedCable2_lines) = Sec_girder1_stayedcable;
        girder1.Section(index_Combination_lines) = Sec_girder1_combination;
        girder1.Section(index_Other_lines) = Sec_girder1_combination;
    end
    
    % 边跨加劲梁       
    if flag_Iyy_SeperatedSystem
        girder2_sectiondata = UserSection(Area_SideSpan_Girder,20,Iyy_StayedCable_Girder,193,36,8); % 定义截面数据，UserSection是用户自定义截面数据，User(A,Ixx,Iyy,Izz,TKy,TKz) ，单位: m
        Name_Section = '边跨主梁Girder-StayedCable部分';
    else
        girder2_sectiondata = UserSection(Area_SideSpan_Girder,20,Iyy_SideSpan_Girder,193,36,8); % 定义截面数据，UserSection是用户自定义截面数据，User(A,Ixx,Iyy,Izz,TKy,TKz) ，单位: m
        Name_Section = '边跨主梁Girder';
    end
    Sec_girder2 = Section(Name_Section,girder2_sectiondata); % 定义截面，后面在定义后面的结构时，使用这里定义的Sec_girder。这里的截面名称'主梁Girder'会出现在Ansys宏文件的注释中，方便检查
    girder2_materialdata = MaterialData_Q345; % 定义材料属性，MaterialData_Q345为内置的Q345钢的材料属性，单位: N, m
    Mat_girder2 = Material('边跨主梁Girder',girder2_materialdata); % 定义材料，后面在定义后面的结构时，使用这里定义的Mat_girder。
    ET_girder2 = Beam188; % 单元类型选择为Ansys中的Beam188单元。

    % 边跨1加劲梁
    L = seg_sidespan_1+zeros(1,21);
    CoordA_girder2 = [CoordA_girder1(1)-sum(L),CoordA_girder1(2),CoordA_girder1(3)];
    CoordB_girder2 = CoordA_girder1;    
    girder2 = obj.buildGirder(CoordA_girder2,CoordB_girder2,L,Sec_girder2,Mat_girder2,ET_girder2);
    obj.addToSpan('SideSpan',1,girder2);

    Point_StayedCable_girder2 = girder2.findPoint('Interval','X','descend',[4*seg_sidespan_1,2*seg_sidespan_1+zeros(1,4),seg_sidespan_1+zeros(1,9)]).sort('X');
    
    % 边跨2加劲梁
    L = seg_sidespan_2+zeros(1,21);
    CoordA_girder3 = CoordB_girder1;
    CoordB_girder3 = [CoordB_girder1(1)+sum(L),CoordB_girder1(2),CoordB_girder1(3)];
    girder3 = obj.buildGirder(CoordA_girder3,CoordB_girder3,L,Sec_girder2,Mat_girder2,ET_girder2);
    obj.addToSpan('SideSpan',2,girder3);
     
    Point_StayedCable_girder3 = girder3.findPoint('Interval','X','ascend',[4*seg_sidespan_2,2*seg_sidespan_2+zeros(1,4),seg_sidespan_2+zeros(1,9)]).sort('X');
    
    %% 自锚锚碇
    % 定义：截面、材料、单元类型
    anchor_sectiondata = UserSection(20.3482,200,1900.1827,1930.,36,8);
    anchor_materialdata = MaterialData_C60;
    Sec_anchor = Section('锚碇Girder',anchor_sectiondata);
    Mat_anchor = Material('锚碇Girder',anchor_materialdata);
    ET_anchor = Beam188;
    
    % 边跨1锚碇
    L = [20,seg_sidespan_1];
    CoordA_anchor1 = [CoordA_girder2(1)-sum(L),CoordA_girder2(2),CoordA_girder2(3)];
    CoordB_anchor1 = CoordA_girder2;
    anchor1 = obj.buildGirder(CoordA_anchor1,CoordB_anchor1,L,Sec_anchor,Mat_anchor,ET_anchor);
    obj.addToSpan('SideSpan',1,anchor1);
    
    % 边跨2锚碇
    L = [seg_sidespan_2,20];
    CoordA_anchor2 = CoordB_girder3;
    CoordB_anchor2 = [CoordB_girder3(1)+sum(L),CoordB_girder3(2),CoordB_girder3(3)];
    anchor2 = obj.buildGirder(CoordA_anchor2,CoordB_anchor2,L,Sec_anchor,Mat_anchor,ET_anchor);
    obj.addToSpan('SideSpan',2,anchor2);
    
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
    Coord_MoveTo_tower1 = [CoordA_girder1(1),CoordA_girder1(2),CoordA_girder1(3)-82.8];% 塔根位置
    tower1 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower1,Sec_tower,Mat_tower,ET_tower);
    Point_MainCable_tower1 = tower1.findPoint("Index","Z","descend",2).sort('Z'); % 主缆索鞍点,按Z正方向排列
    Point_StayedCable_tower1 = tower1.findPoint("Index","Z","descend",3:16).sort('Z'); % 斜拉索锚固位置（还要经过刚臂转化到斜拉索上）
    obj.addToSpan('MainSpan',1,tower1);
    obj.addToSpan('SideSpan',1,tower1);
    
    % 桥塔2
    Coord_MoveTo_tower2 = [CoordB_girder1(1),CoordB_girder1(2),CoordB_girder1(3)-82.8];
    tower2 = obj.buildTowerByInput(Method_Creating,fun_handle,Coord_MoveTo_tower2,Sec_tower,Mat_tower,ET_tower);
    Point_MainCable_tower2 = tower2.findPoint("Index","Z","descend",2).sort('Z');
    Point_StayedCable_tower2 = tower2.findPoint("Index","Z","descend",3:16).sort('Z');
    obj.addToSpan('MainSpan',1,tower2);
    obj.addToSpan('SideSpan',2,tower2);
    
    %% 辅助墩
%     % 定义：截面、材料、单元类型
%     pier_sectiondata = BoxSection(7,7,1,1,1,1);
%     pier_materialdata = MaterialData_C60;
%     Sec_pier = Section('辅助墩Pier',pier_sectiondata);
%     Mat_pier = Material('辅助墩Pier',pier_materialdata);
%     ET_pier = Beam188;
%     
%     % 从CAD中导入桥塔的线模型
%     model_path_pier = 'Example-Pier.txt';
%     Method_Creating = InputFromAutoCAD(model_path_pier);
%     
%     % 辅助墩1
%     fun_handle = @(pier) pier.findPoint('Index','Z','ascend',1);
    Coord_MoveTo_pier1 = [CoordA_girder1(1)-12*seg_sidespan_1,CoordA_girder1(2),CoordA_girder1(3)-53.2];% 辅助墩墩底位置
%     pier1 = obj.buildPierByInput(Method_Creating,fun_handle,Coord_MoveTo_pier1,Sec_pier,Mat_pier,ET_pier);
%     Point_Top_pier1 = pier1.findPoint("Index","Z","descend",2); % 辅助墩横梁中点处
%     
%     % 辅助墩2
    Coord_MoveTo_pier2 = [CoordB_girder1(1)+12*seg_sidespan_2,CoordB_girder1(2),CoordB_girder1(3)-53.2];
%     pier2 = obj.buildPierByInput(Method_Creating,fun_handle,Coord_MoveTo_pier2,Sec_pier,Mat_pier,ET_pier);
%     Point_Top_pier2 = pier2.findPoint("Index","Z","descend",2);

    %% 刚臂
    % 定义：截面、材料、单元类型材料
    rigid_beam_sectiondata = RectangleSection(5,5);
    rigid_beam_materialdata = MaterialData_RigidBeam;
    Sec_rigidbeam = Section('刚臂Rigid Beam',rigid_beam_sectiondata);
    Mat_rigidbeam = Material('刚臂Rigid Beam',rigid_beam_materialdata);
    ET_rigidbeam = Beam188;
    
    % girder1 与 Hanger 之间的RigidBeam，均为按X正方向排列
    offset1 = [0,14.25,4.2];
    offset2 = [0,-14.25,4.2];
    rigidbeam_1 = obj.buildRigidBeamByOffset(Point_Hanger_girder1,girder1,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_2 = obj.buildRigidBeamByOffset(Point_Hanger_girder1,girder1,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    obj.addToSpan('MainSpan',1,rigidbeam_1);
    obj.addToSpan('MainSpan',1,rigidbeam_2);
    % girder1 与 StayedCable 之间的RigidBeam
    rigidbeam_3 = obj.buildRigidBeamByOffset(Point_StayedCable1_girder1,girder1,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_4 = obj.buildRigidBeamByOffset(Point_StayedCable1_girder1,girder1,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_5 = obj.buildRigidBeamByOffset(Point_StayedCable2_girder1,girder1,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_6 = obj.buildRigidBeamByOffset(Point_StayedCable2_girder1,girder1,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    obj.addToSpan('MainSpan',1,rigidbeam_3);
    obj.addToSpan('MainSpan',1,rigidbeam_4);
    obj.addToSpan('MainSpan',1,rigidbeam_5);
    obj.addToSpan('MainSpan',1,rigidbeam_6);
    % girder2 与 StayedCable 之间的RigidBeam
    rigidbeam_7 = obj.buildRigidBeamByOffset(Point_StayedCable_girder2,girder2,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_8 = obj.buildRigidBeamByOffset(Point_StayedCable_girder2,girder2,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    obj.addToSpan('SideSpan',1,rigidbeam_7);
    obj.addToSpan('SideSpan',1,rigidbeam_8);
    % girder3 与 StayedCable 之间的RigidBeam
    rigidbeam_9 = obj.buildRigidBeamByOffset(Point_StayedCable_girder3,girder3,offset1,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_10 = obj.buildRigidBeamByOffset(Point_StayedCable_girder3,girder3,offset2,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    obj.addToSpan('SideSpan',2,rigidbeam_9);
    obj.addToSpan('SideSpan',2,rigidbeam_10);
    
    % tower1 与 StayedCable 之间的RigidBeam，均为按Z正方向排列
    offset3 = [0,2.44,0];
    offset4 = [0,-2.44,0];
    rigidbeam_11 = obj.buildRigidBeamByOffset(Point_StayedCable_tower1,tower1,offset3,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_12 = obj.buildRigidBeamByOffset(Point_StayedCable_tower1,tower1,offset4,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    obj.addToSpan('MainSpan',1,rigidbeam_11);
    obj.addToSpan('SideSpan',1,rigidbeam_11);
    obj.addToSpan('MainSpan',1,rigidbeam_12);
    obj.addToSpan('SideSpan',1,rigidbeam_12);

    % tower2 与 StayedCable 之间的RigidBeam
    rigidbeam_13 = obj.buildRigidBeamByOffset(Point_StayedCable_tower2,tower2,offset3,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    rigidbeam_14 = obj.buildRigidBeamByOffset(Point_StayedCable_tower2,tower2,offset4,Sec_rigidbeam,Mat_rigidbeam,ET_rigidbeam);
    obj.addToSpan('MainSpan',1,rigidbeam_13);
    obj.addToSpan('SideSpan',2,rigidbeam_13);
    obj.addToSpan('MainSpan',1,rigidbeam_14);
    obj.addToSpan('SideSpan',2,rigidbeam_14);
    
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
    stayedcable_1 = obj.buildStayedCable(rigidbeam_3.ConnectPoint,rigidbeam_11.ConnectPoint,rigidbeam_3,rigidbeam_11,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_2 = obj.buildStayedCable(rigidbeam_4.ConnectPoint,rigidbeam_12.ConnectPoint,rigidbeam_4,rigidbeam_12,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    obj.addToSpan('MainSpan',1,stayedcable_1);
    obj.addToSpan('MainSpan',1,stayedcable_2);
    % girder1 与 tower2 之间的 StayedCable
    stayedcable_3 = obj.buildStayedCable(rigidbeam_5.ConnectPoint,rigidbeam_13.ConnectPoint.reverse,rigidbeam_5,rigidbeam_13,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_4 = obj.buildStayedCable(rigidbeam_6.ConnectPoint,rigidbeam_14.ConnectPoint.reverse,rigidbeam_6,rigidbeam_14,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    obj.addToSpan('MainSpan',1,stayedcable_3);
    obj.addToSpan('MainSpan',1,stayedcable_4);
    % girder2 与 tower1 之间的 StayedCable
    stayedcable_5 = obj.buildStayedCable(rigidbeam_7.ConnectPoint,rigidbeam_11.ConnectPoint.reverse,rigidbeam_7,rigidbeam_11,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_6 = obj.buildStayedCable(rigidbeam_8.ConnectPoint,rigidbeam_12.ConnectPoint.reverse,rigidbeam_8,rigidbeam_12,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    obj.addToSpan('SideSpan',1,stayedcable_5);
    obj.addToSpan('SideSpan',1,stayedcable_6);
    % girder3 与 tower2 之间的 StayedCable
    stayedcable_7 = obj.buildStayedCable(rigidbeam_9.ConnectPoint,rigidbeam_13.ConnectPoint,rigidbeam_9,rigidbeam_13,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    stayedcable_8 = obj.buildStayedCable(rigidbeam_10.ConnectPoint,rigidbeam_14.ConnectPoint,rigidbeam_10,rigidbeam_14,Sec_stayedcable,Mat_stayedcable,ET_stayedcable);
    obj.addToSpan('SideSpan',2,stayedcable_7);
    obj.addToSpan('SideSpan',2,stayedcable_8);
    
    
    %% Cable
    % 定义：截面、材料、单元类型材料
    main_cable_sectiondata = CircleSection(0.36/2); % 直径0.36m的圆截面
    main_cable_materialdata = MaterialData_Cable; % 使用内置的 MaterialData_Cable的材料数据
    Sec_cable = Section('主缆Cable',main_cable_sectiondata);
    Mat_cable = Material('主缆Cable',main_cable_materialdata);
    ET_cable = Link10;
    
    % 主跨主缆
    CoordA_cable1 = Point_MainCable_tower1.Coord + [0,0.5,0]; % 左端点坐标
    CoordB_cable1 = Point_MainCable_tower2.Coord + [0,0.5,0]; % 右端点坐标
    L = seg_mainspan+zeros(1,92); % 主缆X向分段，长度n=92
    index_hanger = logical([zeros(1,30-2*count_crosscable),repmat([1,0],1,16+2*count_crosscable),zeros(1,29-2*count_crosscable)]);% 吊杆会在主缆哪些位置悬吊，长度n-1=91，X正方向排列，与Cable.ForcePoint方向相同
    
    weight = obj.getGirderWeight;
    count_hanger = sum(index_hanger);
    P_z = -weight/count_hanger/2; % 主跨加劲梁girder1的总重被主跨的StayedCable平分
    P_h_z = P_z+zeros(1,count_hanger); % 初始吊杆力（吊杆和斜拉索竖向力平分加劲梁自重）zhengfangxiang
    P_h_y = -P_h_z*abs((CoordA_cable1(2)-offset1(2))/(CoordA_cable1(3)-offset1(3)));
    P_h_x = zeros(size(P_h_z));
    
    Z_Om = (CoordA_cable1(3)+CoordB_cable1(3))/2 - sag; % 主缆跨中点Z
    obj.Params.P_girder_z_MainSpan = P_h_z;
    
    [cable1,Output_MS] = obj.buildMainSpanCable(CoordA_cable1,CoordB_cable1,L,index_hanger,P_h_x,P_h_y,P_h_z,Z_Om,Sec_cable,Mat_cable,ET_cable);
    cable2 = obj.symmetrizeCable(cable1); 
    obj.addToSpan('MainSpan',1,cable1);
    obj.addToSpan('MainSpan',1,cable2);
    
    % 边跨1主缆
    CoordA_cable2 = [CoordA_girder2(1)-seg_sidespan_1,CoordA_girder2(2)+16,CoordA_girder2(3)];
    CoordB_cable2 = CoordA_cable1;
    L = seg_sidespan_1+zeros(1,22);
    index_hanger = false(1,21);
    P_h_x = [];
    P_h_y = [];
    P_h_z = [];
    F_x = Output_MS.F_x;
    
    cable3 = obj.buildSideSpanCable(CoordA_cable2,CoordB_cable2,L,index_hanger,P_h_x,P_h_y,P_h_z,F_x,Sec_cable,Mat_cable,ET_cable);
    cable4 = obj.symmetrizeCable(cable3);
    obj.addToSpan('SideSpan',1,cable3);
    obj.addToSpan('SideSpan',1,cable4);
    
    % 边跨2主缆
    CoordA_cable3 = CoordB_cable1;
    CoordB_cable3 = [CoordB_girder3(1)+seg_sidespan_2,CoordB_girder3(2)+16,CoordB_girder3(3)];
    L = seg_sidespan_2+zeros(1,22);
    index_hanger = false(1,21);
    P_h_x = [];
    P_h_y = [];
    P_h_z = [];
    F_x = Output_MS.F_x;
    
    cable5 = obj.buildSideSpanCable(CoordA_cable3,CoordB_cable3,L,index_hanger,P_h_x,P_h_y,P_h_z,F_x,Sec_cable,Mat_cable,ET_cable);
    cable6 = obj.symmetrizeCable(cable5);
    obj.addToSpan('SideSpan',2,cable5);
    obj.addToSpan('SideSpan',2,cable6);
    
    cable_PositiveY = [cable3,cable1,cable5];
    cable_NegativeY = [cable4,cable2,cable6];
    cable_PositiveY.merge;
    cable_NegativeY.merge;
    %% Hanger
    % 定义：截面、材料、单元类型材料
    hanger_sectiondata = CircleSection(0.0731/2);
    hanger_materialdata = MaterialData_Q345;
    Sec_hanger = Section('吊杆Hanger',hanger_sectiondata);
    Mat_hanger = Material('吊杆Hanger',hanger_materialdata);
    ET_hanger = Link10;
    
    hanger_1 = obj.buildHanger(rigidbeam_1.ConnectPoint,cable1.ConnectPoint,rigidbeam_1,cable1,Sec_hanger,Mat_hanger,ET_hanger);
    hanger_2 = obj.buildHanger(rigidbeam_2.ConnectPoint,cable2.ConnectPoint,rigidbeam_2,cable2,Sec_hanger,Mat_hanger,ET_hanger);
    obj.addToSpan('MainSpan',1,hanger_1);
    obj.addToSpan('MainSpan',1,hanger_2);
    
    %% 赋予斜拉索和吊杆初始力
    stayedcable_list = obj.findStructureByClass('StayedCable');
    hanger_list = obj.findStructureByClass('Hanger');
    hanger_stayedcable_list = [stayedcable_list,hanger_list];
    obj.setForceTo(hanger_stayedcable_list,P_z+zeros(1,length(hanger_stayedcable_list)))
    
    %% 耦合 Coupling

    % 自锚耦合
    if obj.SelfAnchored
        anchor1_masterpoint = anchor1.Point.findPointByRange(cable3.PointA.X,[],[]);
        anchor2_masterpoint = anchor2.Point.findPointByRange(cable5.PointB.X,[],[]);
        CP_selfanchor_1 = obj.addCoupling(anchor1_masterpoint,[cable3.PointA,cable4.PointA],{'Ux','Uy','Uz'},'Name','自锚耦合1');
        CP_selfanchor_2 = obj.addCoupling(anchor2_masterpoint,[cable5.PointB,cable6.PointB],{'Ux','Uy','Uz'},'Name','自锚耦合2');
    end

    % Tower和Girder之间的耦合
    tower1_masterpoint = tower1.Point.findPointByRange([],0,-19.15);
    tower2_masterpoint = tower2.Point.findPointByRange([],0,-19.15);
    CP_tower1_girder = obj.addCoupling(tower1_masterpoint,girder1.PointA,{'Uy','Uz','Rotx'},'Name','塔梁耦合1');
    CP_tower2_girder = obj.addCoupling(tower2_masterpoint,girder1.PointB,{'Uy','Uz','Rotx'},'Name','塔梁耦合2');

    % 辅助墩墩顶耦合
%     girder2_salvepoint = girder2.Point.findPointByRange(Coord_MoveTo_pier1(1),[],[]);
%     girder3_slavepoint = girder3.Point.findPointByRange(Coord_MoveTo_pier2(1),[],[]);
%     CP_pier1_girder = obj.addCoupling(Point_Top_pier1,girder2_salvepoint,{'Uz'},'Name','辅助墩、梁耦合1');
%     CP_pier2_girder = obj.addCoupling(Point_Top_pier2,girder3_slavepoint,{'Uz'},'Name','辅助墩、梁耦合2');

    % 主缆与塔耦合
    CP_tower1_cable = obj.addCoupling(Point_MainCable_tower1,[cable1.PointA,cable2.PointA],{'Ux','Uy','Uz'},'Name','主缆、塔耦合1');
    CP_tower2_cable = obj.addCoupling(Point_MainCable_tower2,[cable1.PointB,cable2.PointB],{'Ux','Uy','Uz'},'Name','主缆、梁耦合2');


    %% 约束 Constraint
    
    % 塔底约束
    all_DoF = DoF.All.Name; % {'Ux','Uy','Uz','Rotx','Roty','Rotz'}
    constraint1 = obj.addConstraint(tower1.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','塔底固结1');
    constraint2 = obj.addConstraint(tower2.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','塔底固结2');
    
    % 梁端约束
    support_DoF_1 = {'Uy','Uz','Rotx'};
    support_DoF_2 = {'Uy','Uz','Rotx'};
    constraint3 = obj.addConstraint(anchor1.PointA,support_DoF_1,zeros(1,length(support_DoF_1)),'Name','梁端约束1');
    constraint4 = obj.addConstraint(anchor2.PointB,support_DoF_2,zeros(1,length(support_DoF_2)),'Name','梁端约束2');
    
    % 辅助墩墩底约束
%     constraint5 = obj.addConstraint(pier1.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','辅助墩固结1');
%     constraint6 = obj.addConstraint(pier2.PointBottom,all_DoF,zeros(1,length(all_DoF)),'Name','辅助墩固结2');

    % 辅助墩处加劲梁约束
    girder2_PierPoint = girder2.Point.findPointByRange(Coord_MoveTo_pier1(1),[],[]);
    girder3_PierPoint = girder3.Point.findPointByRange(Coord_MoveTo_pier2(1),[],[]);
    constraint5 = obj.addConstraint(girder2_PierPoint,support_DoF_2,zeros(1,length(support_DoF_2)),'Name','辅助墩处加劲梁约束1');
    constraint6 = obj.addConstraint(girder3_PierPoint,support_DoF_2,zeros(1,length(support_DoF_2)),'Name','辅助墩处加劲梁约束2');

    % 主缆地锚固结
    if ~obj.SelfAnchored
        support_DoF_5 = {'Ux','Uy','Uz'};
        support_DoF_6 = {'Ux','Uy','Uz'};
        support_DoF_7 = {'Ux','Uy','Uz'};
        support_DoF_8 = {'Ux','Uy','Uz'};
        constraint7 = obj.addConstraint(cable3.PointA,support_DoF_5,zeros(1,length(support_DoF_5)),'Name','地锚固结1');
        constraint8 = obj.addConstraint(cable4.PointA,support_DoF_6,zeros(1,length(support_DoF_6)),'Name','地锚固结2');
        constraint9 = obj.addConstraint(cable5.PointB,support_DoF_7,zeros(1,length(support_DoF_7)),'Name','地锚固结3');
        constraint10 = obj.addConstraint(cable6.PointB,support_DoF_8,zeros(1,length(support_DoF_8)),'Name','地锚固结4');
    end
    
    % 跨中X向约束
    support_DoF_3 = {'Ux'};
    point_center = girder1.PointCenter; % 跨中点
    constraint11 = obj.addConstraint(point_center,support_DoF_3,zeros(1,length(support_DoF_3)),'Name','跨中点X向固定');
        
    %% 荷载 Load
    
    % % 选择作用位置，中跨右半跨
    % XSorted_girder1_line = girder1.findLineByCenterCoord('X','ascend');
    % half_len = floor(length(XSorted_girder1_line)/2);
    % HalfSpanLoad_girder1_line = XSorted_girder1_line(1:half_len);
    % 
    % HalfSpanLoad = UniformLoad(HalfSpanLoad_girder1_line,"Z",-100);
    % obj.addLoad(HalfSpanLoad,'Name','主跨 左半跨荷载');
    % 
    % 二期恒载
%     FullSpanLoad_girder1_line = girder1.findLineByCenterCoord('X','ascend');
%     FullSpanLoad_girder2_line = girder2.findLineByCenterCoord('X','ascend');
%     FullSpanLoad_girder3_line = girder3.findLineByCenterCoord('X','ascend');
%     FullSpanLoad_girder_line = [FullSpanLoad_girder1_line,FullSpanLoad_girder2_line,FullSpanLoad_girder3_line];
%     FullSpanLoad = UniformLoad(FullSpanLoad_girder_line,'Z',-190000);
%     obj.addLoad(FullSpanLoad,'Name','二期恒载');
    % 
    % % 跨中集中荷载
    % girder1_XPoint = girder1.Point.sort('X');
    % girder1_MidspanPoint = girder1_XPoint([round(length(girder1_XPoint)/2),round(length(girder1_XPoint)/2)+1]);
    % MidSpanLoad_Y  = ConcentratedForce(girder1_MidspanPoint,"Y",[100,200]);
    % obj.addLoad(MidSpanLoad_Y,'Name','中跨跨中Y向集中荷载')
    
    %% 设置输出方式
    obj.OutputMethod = OutputToAnsys(obj);
end
function [index_Hanger_lines,index_StayedCable1_lines,index_StayedCable2_lines,index_Combination_lines,index_Other_lines] = findMainSpanDivisionIndex(girderobj,Point_Hanger_girder,Point_StayedCable1_girder,Point_StayedCable2_girder)
    % 将
    lines_girder1 = girderobj.Line;
    IPoint_girder1 = [lines_girder1.IPoint];
    JPoint_girder1 = [lines_girder1.JPoint];
    X_IPoint_girder1 = [IPoint_girder1.X];
    X_JPoint_girder1 = [JPoint_girder1.X];
    PointA_Hanger_girder1 = Point_Hanger_girder(1);
    PointB_Hanger_girder1 = Point_Hanger_girder(end);
    PointB_StayedCable1_girder1 = Point_StayedCable1_girder(end);
    PointA_StayedCable2_girder1 = Point_StayedCable2_girder(1);
    index_Hanger_lines = false(1,length(lines_girder1));
    index_StayedCable1_lines = false(1,length(lines_girder1));
    index_StayedCable2_lines = false(1,length(lines_girder1));
    index_Combination_lines = false(1,length(lines_girder1));
    index_Other_lines = false(1,length(lines_girder1));
    isInHanegrSpan = false;    
    for i=1:length(lines_girder1)
        XRange_line = [min(X_IPoint_girder1(i),X_JPoint_girder1(i)),max(X_IPoint_girder1(i),X_JPoint_girder1(i))];
        if (PointA_Hanger_girder1.X >= XRange_line(1)) && (PointA_Hanger_girder1.X < XRange_line(2)) % 左边端吊索点位于该line范围内
            isInHanegrSpan = true;
        end
        if (PointB_Hanger_girder1.X >= XRange_line(1)) && (PointB_Hanger_girder1.X < XRange_line(2)) % 有边端吊索点位于该line范围内
            isInHanegrSpan = false;
        end
        if isInHanegrSpan
            index_Hanger_lines(i) = true;
        end
    end
    isInStayedCable1 = true;    
    for i=1:length(lines_girder1)
        XRange_line = [min(X_IPoint_girder1(i),X_JPoint_girder1(i)),max(X_IPoint_girder1(i),X_JPoint_girder1(i))];
        if (PointB_StayedCable1_girder1.X >= XRange_line(1)) && (PointB_StayedCable1_girder1.X < XRange_line(2)) % 左边端吊索点位于该line范围内
            isInStayedCable1 = false;
        end
        if isInStayedCable1
            index_StayedCable1_lines(i) = true;
        end
    end
    isInStayedCable1 = false;    
    for i=1:length(lines_girder1)
        XRange_line = [min(X_IPoint_girder1(i),X_JPoint_girder1(i)),max(X_IPoint_girder1(i),X_JPoint_girder1(i))];
        if (PointA_StayedCable2_girder1.X >= XRange_line(1)) && (PointA_StayedCable2_girder1.X < XRange_line(2)) % 左边端吊索点位于该line范围内
            isInStayedCable1 = true;
        end
        if isInStayedCable1
            index_StayedCable2_lines(i) = true;
        end
    end
    for i=1:length(lines_girder1)
        if index_Hanger_lines(i) && index_StayedCable1_lines(i) % 既是Hanger，又是StayedCable1
            index_Combination_lines(i) = true;
        elseif index_Hanger_lines(i) && index_StayedCable2_lines(i) % 既是Hanger，又是StayedCable2
            index_Combination_lines(i) = true;
        elseif ~(index_Hanger_lines(i)) && ~(index_StayedCable1_lines(i)) && ~(index_StayedCable2_lines(i))  % 既不是Hanger，又不是StayedCable1
            index_Other_lines(i) = true;
        end
    end
end