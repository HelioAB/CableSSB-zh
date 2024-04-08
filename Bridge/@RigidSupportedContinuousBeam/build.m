function build(obj)
    % 显示正在做什么
    disp('Is building a Rigid Supported Continuous Beam...')
    
    % 将原Bridge复制到一个新的找合理成桥状态专用的Bridge对象中去
    metaobj_from = metaclass(obj.OriginalBridge);
    metaobj_to = metaclass(obj);
    props_from = {metaobj_from.PropertyList.Name};
    props_to = {metaobj_to.PropertyList.Name};
    for i=1:length(props_from)
        if any(strcmp(props_to,props_from{i}))
            obj.(props_from{i}) = obj.OriginalBridge.(props_from{i});
        end
    end
    
    % 提取出 Hanger、Cable、StayedCable、Pier
    array2cell = @(structure) [structure]; % function_handle，通过cellfun将cell转换为对象数组

    [hanger_list,index_hanger] = obj.findStructureByClass('Hanger');
    obj.ReplacedHanger = cellfun(array2cell,hanger_list);
    [cable_list,index_cable] = obj.findStructureByClass('Cable');
    obj.ReplacedCable = cellfun(array2cell,cable_list);
    [stayedcable_list,index_stayedcable] = obj.findStructureByClass('StayedCable');
    obj.ReplacedStayedCable = cellfun(array2cell,stayedcable_list);
    [tower_list,index_tower] = obj.findStructureByClass('Tower');
    obj.ReplacedTower = cellfun(array2cell,tower_list);
    [rigidbeam_list,index_rigidbeam] = obj.findStructureByClass('RigidBeam');
    obj.ReplacedRigidBeam = cellfun(array2cell,rigidbeam_list);
    [pier_list,index_pier] = obj.findStructureByClass('Pier');
    obj.ReplacedPier = cellfun(array2cell,pier_list);

    % 在bridge_findState中删除与 Hanger、Cable、StayedCable相关的和Pier:（并不是把对象完全删除了，而是把它们从*List属性中去除了）
    % Material、Section、ElementType、ElementDivision、Coupling、Load、Constraint
    delete_structure_index = index_hanger | index_cable | index_stayedcable | index_tower | index_rigidbeam | index_pier;
    obj.MaterialList(delete_structure_index) = [];
    obj.SectionList(delete_structure_index) = [];
    obj.ElementTypeList(delete_structure_index) = [];
    obj.ElementDivisionList(delete_structure_index) = [];
    obj.StructureList(delete_structure_index) = [];
    
    % 删除与Hanger、Cable、StayedCable、Pier相关的Constraint和Coupling
    [coupling_Hanger,index_coupling_Hanger] = obj.findCouplingByStructure(hanger_list);
    [coupling_Cable,index_coupling_Cable] = obj.findCouplingByStructure(cable_list);
    [coupling_StayedCable,index_coupling_StayedCable] = obj.findCouplingByStructure(stayedcable_list);
    [coupling_Pier,index_coupling_Pier] = obj.findCouplingByStructure(pier_list);
    [coupling_Tower,index_coupling_Tower] = obj.findCouplingByStructure(tower_list);
    [coupling_RigidBeam,index_coupling_RigidBeam] = obj.findCouplingByStructure(rigidbeam_list);
    delete_coupling = index_coupling_Hanger | index_coupling_Cable | index_coupling_StayedCable | index_coupling_Pier | index_coupling_Tower | index_coupling_RigidBeam;
    
    [constraint_Hanger,index_constraint_Hanger] = obj.findConstraintByStructure(hanger_list);
    [constraint_Cable,index_constraint_Cable] = obj.findConstraintByStructure(cable_list);
    [constraint_StayedCable,index_constraint_StayedCable] = obj.findConstraintByStructure(stayedcable_list);
    [constraint_Pier,index_constraint_Pier] = obj.findConstraintByStructure(pier_list);
    [constraint_Tower,index_constraint_Tower] = obj.findConstraintByStructure(tower_list);
    [constraint_RigidBeam,index_constraint_RigidBeam] = obj.findConstraintByStructure(rigidbeam_list);
    delete_constraint = index_constraint_Hanger | index_constraint_Cable | index_constraint_StayedCable | index_constraint_Pier | index_constraint_Tower | index_constraint_RigidBeam;
    
    obj.CouplingList(delete_coupling) = [];
    obj.ConstraintList(delete_constraint) = [];

    deleted_constraint = [constraint_Hanger,constraint_Cable,constraint_StayedCable,constraint_Pier,constraint_Tower,constraint_RigidBeam];
    index_constraint = false(1,length(deleted_constraint));
    for i=1:length(deleted_constraint)
        if isempty(deleted_constraint{i})
            index_constraint(i) = true;
        end
    end
    deleted_constraint(index_constraint) = [];
    deleted_coupling = [coupling_Hanger,coupling_Cable,coupling_StayedCable,coupling_Pier,coupling_Tower,coupling_RigidBeam];
    index_coupling = false(1,length(deleted_coupling));
    for i=1:length(deleted_coupling)
        if isempty(deleted_coupling{i})
            index_coupling(i) = true;
        end
    end
    deleted_coupling(index_coupling) = [];
    DelConstraint = [];
    for i=1:length(deleted_constraint)
        DelConstraint = [DelConstraint,deleted_constraint{i}];
    end
    DelCoupling = [];
    for i=1:length(deleted_coupling)
        DelCoupling = [DelCoupling,deleted_coupling{i}];
    end
    obj.DeletedConstraint = DelConstraint.unique();
    obj.DeletedCoupling = DelCoupling.unique();
    

    % 找到Girder上的所有点
    girders = obj.findStructureByClass('Girder');
    girder_points = [];
    for i=1:length(girders)
        girder = girders{i};
        girder_points = [girder_points,girder.Point];
    end

    % 使用Constraint代替原来Pier的Coupling
    count = 0;
    for i=1:length(coupling_Pier)
        for j=1:length(coupling_Pier{i})
            coupling = coupling_Pier{i};
            coupling_points = [coupling(j).SlavePoint,coupling(j).MasterPoint];
            for k=1:length(coupling_points)
                if any(girder_points == coupling_points(k))
                    constraint_point = coupling_points(k);
                end
            end
            dof = coupling(j).DoF.Name;
            count = count + 1;
            obj.addConstraint(constraint_point,dof,zeros(1,length(dof)),'Name',sprintf('辅助墩-梁 Coupling %d',count));
        end
    end

    % 使用Constraint代替原来Tower的Coupling
    count = 0;
    for i=1:length(coupling_Tower)
        for j=1:length(coupling_Tower{i})
            coupling = coupling_Tower{i};
            coupling_points = [coupling(j).SlavePoint,coupling(j).MasterPoint];
            for k=1:length(coupling_points)
                if any(girder_points == coupling_points(k))
                    constraint_point = coupling_points(k);
                end
            end
            dof = coupling(j).DoF.Name;
            count = count + 1;
            obj.addConstraint(constraint_point,dof,zeros(1,length(dof)),'Name',sprintf('塔-梁 Coupling %d',count));
        end
    end

    % 将Beam18*的AdditionalNode改为0
    for i=1:length(obj.ElementTypeList)
        ET = obj.ElementTypeList{i};
        if strcmpi(class(ET),'Beam188') || strcmpi(class(ET),'Beam189') % 只有Beam188和Beam189才能修改AdditionalNode属性
            ET.AdditionalNode = 0; % 将额外节点个数设置为0
        end
    end
    
    % 寻找刚性支撑点
    rigidbeams = obj.OriginalBridge.findStructureByClass('RigidBeam');
    supported_points = [];
    for i=1:length(rigidbeams)
        rigidbeam = rigidbeams{i};
        supported_points = [supported_points,rigidbeam.findGirderPoint];
    end
    supported_points_unique = supported_points.unique;

    % 添加刚性支撑
    dof = {'Uz','Rotx','Roty'};
    for i=1:length(supported_points_unique)
        obj.addConstraint(supported_points_unique(i),dof,zeros(1,length(dof)),'Name',sprintf('刚性支撑 %d',i));
    end

    % 支撑点
    sorted_supported_point = supported_points_unique.sort('X');
    obj.XCoordOfPz = [sorted_supported_point.X];
    obj.SupportedPoint = sorted_supported_point;
end