function OnlyCableBridge = getOnlyCableBridge(obj)
    OnlyCableBridge = Bridge();
    ReplacedCables = obj.ReplacedCable;
    ReplacedHangers = obj.ReplacedHanger;
    ReplacedStayedCables = obj.ReplacedStayedCable;
    OriginalBridge = obj.OriginalBridge;

    % 1. 恢复所有的缆索
    for i=1:length(ReplacedCables)
        cable = ReplacedCables(i);
        section = cable.Section;
        material = cable.Material;
        element_type = cable.ElementType;
        division_num = cable.ElementDivisionNum;
        OnlyCableBridge.updateList('Structure',cable,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    end
    for i=1:length(ReplacedHangers)
        hanger = ReplacedHangers(i);
        section = hanger.Section;
        material = hanger.Material;
        element_type = hanger.ElementType;
        division_num = hanger.ElementDivisionNum;
        OnlyCableBridge.updateList('Structure',hanger,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    end
    for i=1:length(ReplacedStayedCables)
        stayedcable = ReplacedStayedCables(i);
        section = stayedcable.Section;
        material = stayedcable.Material;
        element_type = stayedcable.ElementType;
        division_num = stayedcable.ElementDivisionNum;
        OnlyCableBridge.updateList('Structure',stayedcable,'Section',section.unique, ...
                    'Material',material,'ElementType',element_type,'ElementDivision',division_num)
    end

    % 2. 主缆两端固结
    cable_constraint_list = OriginalBridge.findConstraintByStructure(ReplacedCables);
    ConstraintList = {};
    for i=1:length(cable_constraint_list)
        constraint = cable_constraint_list{i};
        if ~isempty(constraint)
            ConstraintList{1,end+1} = constraint;
        end
    end
    OnlyCableBridge.ConstraintList = ConstraintList;

    cable_coupling_list = OriginalBridge.findCouplingByStructure(ReplacedCables);
    SlavePoints = [];
    for i=1:length(cable_constraint_list)
        coupling = cable_coupling_list{i};
        if ~isempty(coupling)
            for j=1:length(coupling)
                SlavePoints = [SlavePoints,coupling.SlavePoint];
            end
        end
    end
    CableTowerPoint = SlavePoints.unique;
    for i=1:length(CableTowerPoint)
        point = CableTowerPoint(i);
        OnlyCableBridge.addConstraint(point,{'Ux','Uy','Uz'},zeros(1,3),'Name',sprintf('主缆-塔锚固%d',i));
    end
    
    % 3. 斜拉索主塔端固结
    TowerPoints = [];
    for i=1:length(ReplacedStayedCables)
        stayed_cable = ReplacedStayedCables(i);
        TowerPoints = [TowerPoints,stayed_cable.findTowerPoint];
    end
    StayedCableTowerPoint = TowerPoints.unique;
    for i=1:length(StayedCableTowerPoint)
        point = StayedCableTowerPoint(i);
        OnlyCableBridge.addConstraint(point,{'Ux','Uy','Uz'},zeros(1,3),'Name',sprintf('斜拉索-塔锚固%d',i));
    end
    
    max_iter = obj.Iter_Optimization;
    iter_Pz = obj.Result_Iteration.Iter_Pz;
    Pz = iter_Pz(max_iter);
    X = obj.XCoordOfPz;

    len_stayedcable = length(ReplacedStayedCables);
    Load_StayedCableForce = cell(1,3*len_stayedcable);
    for i=1:length(ReplacedStayedCables)
        stayed_cable = ReplacedStayedCables(i);
        girder_point = stayed_cable.findGirderPoint;
    % 4. 斜拉索主梁端受力
        P_girder_z = obj.getGirderPz(stayed_cable,X,Pz);
        [~,~,~,P_girder_x,P_girder_y,P_girder_z] = stayed_cable.getP(P_girder_z);
        load_girder_x = ConcentratedForce(girder_point,'X',P_girder_x);
        load_girder_y = ConcentratedForce(girder_point,'Y',P_girder_y);
        load_girder_z = ConcentratedForce(girder_point,'Z',P_girder_z);
        load_girder_x.Name = [stayed_cable.Name,'_GirderForce_X'];
        load_girder_y.Name = [stayed_cable.Name,'_GirderForce_Y'];
        load_girder_z.Name = [stayed_cable.Name,'_GirderForce_Z'];
        Load_StayedCableForce(1,(i-1)*3+1:(i)*3) = {load_girder_x,load_girder_y,load_girder_z};

    % 5. 斜拉索主梁端X、Y固定
        for j=1:length(girder_point)
            OnlyCableBridge.addConstraint(girder_point(j),{'Uy'},zeros(1,1),'Name',sprintf('斜拉索%d-主梁端X、Y固定%d',i,j));
        end
        
    end



    % 6. 吊索主梁端受力
    len_hanger = length(ReplacedHangers);
    Load_HangerForce = cell(1,3*len_hanger);
    for i=1:length(ReplacedHangers)
        hanger = ReplacedHangers(i);
        P_girder_z = obj.getGirderPz(hanger,X,Pz);
        [~,~,~,P_girder_x,P_girder_y,P_girder_z] = hanger.getP(P_girder_z);
        girder_point = hanger.findGirderPoint;
        load_girder_x = ConcentratedForce(girder_point,'X',P_girder_x);
        load_girder_y = ConcentratedForce(girder_point,'Y',P_girder_y);
        load_girder_z = ConcentratedForce(girder_point,'Z',P_girder_z);
        load_girder_x.Name = [hanger.Name,'_GirderForce_X'];
        load_girder_y.Name = [hanger.Name,'_GirderForce_Y'];
        load_girder_z.Name = [hanger.Name,'_GirderForce_Z'];
        Load_HangerForce(1,(i-1)*3+1:(i)*3) = {load_girder_x,load_girder_y,load_girder_z};    
    % 7. 吊索主梁端X、Y固定
        for j=1:length(girder_point)
            OnlyCableBridge.addConstraint(girder_point(j),{'Uy'},zeros(1,1),'Name',sprintf('吊索%d-主梁端X、Y固定%d',i,j));
        end
    end
    
    
    OnlyCableBridge.LoadList = [Load_StayedCableForce,Load_HangerForce];
end