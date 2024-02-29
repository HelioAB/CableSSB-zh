function build(obj)
    main_cable_sectiondata = CircleSection(0.36/2); % 直径0.36m的圆截面
    main_cable_materialdata = MaterialData_Cable; % 使用内置的 MaterialData_Cable的材料数据
    Sec_cable = Section('主缆Cable',main_cable_sectiondata);
    Mat_cable = Material('主缆Cable',main_cable_materialdata);
    ET_cable = Link10;
    
    % 主跨主缆
    CoordA_cable1 = [0,0,0]; % 左端点坐标
    CoordB_cable1 = [690,0,0]; % 右端点坐标
    L = 7.5+zeros(1,92); % 主缆X向分段，长度n=92
    index_hanger = logical([0,repmat([1,0],1,45)]);% 吊杆会在主缆哪些位置悬吊，长度n-1=91
    
    count_hanger = sum(index_hanger);
    P_z = -2e6;
    P_h_z_mainspan = (P_z+zeros(1,count_hanger)).*(1+rand(1,45)/3); % 初始吊杆力（吊杆和斜拉索竖向力平分加劲梁自重）
    P_h_y = (P_h_z_mainspan*0.13).*(1+rand(1,45)/3);
    P_h_x = zeros(size(P_h_z_mainspan));
    
    Z_Om = CoordA_cable1(3) - 100; % 跨中点的Z向位置
    obj.Params.P_girder_z_MainSpan = P_h_z_mainspan;
    
    [cable1,Output_MS] = obj.buildMainSpanCable(CoordA_cable1,CoordB_cable1,L,index_hanger,P_h_x,P_h_y,P_h_z_mainspan,Z_Om,Sec_cable,Mat_cable,ET_cable);
    
    %% 约束 Constraint
    
    % 塔顶约束
    support_DoF = {'Ux','Uy','Uz'};
    constraint5 = obj.addConstraint(cable1.PointA,support_DoF,zeros(1,length(support_DoF)),'Name','塔顶约束1');
    constraint7 = obj.addConstraint(cable1.PointB,support_DoF,zeros(1,length(support_DoF)),'Name','塔顶约束3');

    %% Load
    % 跨中集中荷载
    cable_force_point = cable1.ConnectPoint;
    load = ConcentratedForce(cable_force_point,'Z',P_h_z_mainspan);
    obj.addLoad(load,'Name','中跨跨中Z向集中荷载')

    load = ConcentratedForce(cable_force_point,'Y',P_h_y);
    obj.addLoad(load,'Name','中跨跨中Z向集中荷载')

    obj.OutputMethod = OutputToAnsys(obj);
    obj.OutputMethod.WorkPath = 'C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\EmptyCable-test';
    obj.OutputMethod.APDLFilePath = 'C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\EmptyCable-test\main.mac';
    obj.OutputMethod.ResultFilePath = 'C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\EmptyCable-test\Susp.out';
    obj.output
end