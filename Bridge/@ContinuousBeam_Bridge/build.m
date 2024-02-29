function build(obj)
    %% 加劲梁
    % 单位：N, m
    % 方向：X：顺桥向；Y：横桥向；Z:竖向。XYZ坐标系满足右手系
    % 定义：截面、材料、单元类型
    girder_sectiondata = UserSection(5.3482,20,190.1827,193,36,8); % 定义截面数据，UserSection是用户自定义截面数据，User(A,Ixx,Iyy,Izz,TKy,TKz) ，单位: m
    girder_materialdata = MaterialData_C60; % 定义材料属性，MaterialData_Q345为内置的Q345钢的材料属性，单位: N, m
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
    
    % 边跨2加劲梁
    L = 7.5+zeros(1,21);
    CoordA_girder3 = CoordB_girder1;
    CoordB_girder3 = [1004.7,0,-4.2];
    girder3 = obj.buildGirder(CoordA_girder3,CoordB_girder3,L,Sec_girder,Mat_girder,ET_girder);

    %% 桥墩
    
    %% 耦合 Coupling

    % 自锚耦合
    CP_selfanchor_1 = obj.addCoupling(girder2.PointA,[cable3.PointA,cable4.PointA],{'Ux','Uy','Uz'},'Name','自锚耦合1','isCableRelated',true);% 与缆索有关
    CP_selfanchor_2 = obj.addCoupling(girder3.PointB,[cable5.PointB,cable6.PointB],{'Ux','Uy','Uz'},'Name','自锚耦合2','isCableRelated',true);

    % Tower和Girder之间的耦合
    tower1_masterpoint = tower1.Point.findPointByRange([],[0],[-19.15]);
    tower2_masterpoint = tower2.Point.findPointByRange([],[0],[-19.15]);
    CP_tower1_girder = obj.addCoupling(tower1_masterpoint,[girder1.PointA],{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合1','isCableRelated',false);% 与缆索无关
    CP_tower2_girder = obj.addCoupling(tower2_masterpoint,[girder1.PointB],{'Ux','Uy','Uz','Rotx'},'Name','塔梁耦合2','isCableRelated',false);
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
    
    %% 荷载 Load
    
    % 选择作用位置，中跨右半跨
    XSorted_girder1_line = girder1.findLineByCenterCoord('X','ascend');
    half_len = floor(length(XSorted_girder1_line)/2);
    HalfSpanLoad_girder1_line = XSorted_girder1_line(1:half_len);
    
    HalfSpanLoad = UniformLoad(HalfSpanLoad_girder1_line,"Z",-100);
    obj.addLoad(HalfSpanLoad,'Name','主跨 左半跨荷载');
    
    % 边跨满跨荷载
    FullSpanLoad_girder2_line = girder2.findLineByCenterCoord('X','ascend');
    FullSpanLoad = UniformLoad(FullSpanLoad_girder2_line,'Z',-120);
    obj.addLoad(FullSpanLoad,'Name','边跨1 满跨荷载');
    
    % 跨中集中荷载
    girder1_XPoint = girder1.Point.sort('X');
    girder1_MidspanPoint = girder1_XPoint([round(length(girder1_XPoint)/2),round(length(girder1_XPoint)/2)+1]);
    MidSpanLoad_Y  = ConcentratedForce(girder1_MidspanPoint,"Y",[100,200]);
    obj.addLoad(MidSpanLoad_Y,'Name','中跨跨中Y向集中荷载')
    
    %% 设置输出方式
    obj.OutputMethod = OutputToAnsys(obj);
end