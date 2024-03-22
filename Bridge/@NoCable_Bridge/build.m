function build(obj)
    % 显示正在做什么
    disp('Is building a Brigde without Cable System...')

    % 将原Bridge复制到一个新的找合理成桥状态专用的Bridge对象中去
    metaobj_from = metaclass(obj.OriginalBridge);
    props_from = {metaobj_from.PropertyList.Name};
    for i=1:length(props_from)
        obj.(props_from{i}) = obj.OriginalBridge.(props_from{i});
    end
    % 提取出 Hanger、Cable、StayedCable、Pier
    array2cell = @(structure) [structure]; % function_handle，通过cellfun将cell转换为对象数组
    [hanger_list,index_hanger] = obj.findStructureByClass('Hanger');
    obj.ReplacedHanger = cellfun(array2cell,hanger_list);
    [cable_list,index_cable] = obj.findStructureByClass('Cable');
    obj.ReplacedCable = cellfun(array2cell,cable_list);
    [stayedcable_list,index_stayedcable] = obj.findStructureByClass('StayedCable');
    obj.ReplacedStayedCable = cellfun(array2cell,stayedcable_list);
    [pier_list,index_pier] = obj.findStructureByClass('Pier');
    obj.ReplacedPier = cellfun(array2cell,pier_list);

    % 在bridge_findState中删除与 Hanger、Cable、StayedCable相关的和Pier:（并不是把对象完全删除了，而是把它们从*List属性中去除了）
    % Material、Section、ElementType、ElementDivision、Coupling、Load、Constraint
    delete_structure_index = index_hanger | index_cable | index_stayedcable | index_pier;
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
    delete_coupling = index_coupling_Hanger | index_coupling_Cable | index_coupling_StayedCable | index_coupling_Pier;
    [constraint_Hanger,index_constraint_Hanger] = obj.findConstraintByStructure(hanger_list);
    [constraint_Cable,index_constraint_Cable] = obj.findConstraintByStructure(cable_list);
    [constraint_StayedCable,index_constraint_StayedCable] = obj.findConstraintByStructure(stayedcable_list);
    [constraint_Pier,index_constraint_Pier] = obj.findConstraintByStructure(pier_list);
    delete_constraint = index_constraint_Hanger | index_constraint_Cable | index_constraint_StayedCable | index_constraint_Pier;
    obj.CouplingList(delete_coupling) = [];
    obj.ConstraintList(delete_constraint) = [];
    deleted_constraint = [constraint_Hanger,constraint_Cable,constraint_StayedCable,constraint_Pier];
    index_constraint = false(1,length(deleted_constraint));
    for i=1:length(deleted_constraint)
        if isempty(deleted_constraint{i})
            index_constraint(i) = true;
        end
    end
    deleted_constraint(index_constraint) = [];
    deleted_coupling = [coupling_Hanger,coupling_Cable,coupling_StayedCable,coupling_Pier];
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

    % 使用Constraint代替原来Pier的Coupling
    for i=1:length(coupling_Pier)
        girder_point = coupling_Pier{i}.SlavePoint;
        dof = coupling_Pier{i}.DoF.Name;
        obj.addConstraint(girder_point,dof,zeros(1,length(dof)),'Name',['辅助墩固结',num2str(i)]);
    end

    % 将Beam18*的AdditionalNode改为0
    for i=1:length(obj.ElementTypeList)
        ET = obj.ElementTypeList{i};
        if strcmpi(class(ET),'Beam188') || strcmpi(class(ET),'Beam189') % 只有Beam188和Beam189才能修改AdditionalNode属性
            ET.AdditionalNode = 0; % 将额外节点个数设置为0
        end
    end
    
    % 将斜拉索、吊索拉力替换为集中力
    average_weight = obj.getAverageGirderWeight;
    X_Hanger = obj.OriginalBridge.getSortedGirderPointXCoord(obj.OriginalBridge.findStructureByClass('Hanger'));
    Pz_Hanger = average_weight + zeros(1,length(X_Hanger));
    X_StayedCable = obj.OriginalBridge.getSortedGirderPointXCoord(obj.OriginalBridge.findStructureByClass('StayedCable'));
    Pz_StayedCable = average_weight + zeros(1,length(X_StayedCable));

    obj.XCoordOfPz = sort([X_Hanger,X_StayedCable]);

    % 将主缆替换为集中力
    obj.LoadList = {}; % 修改obj.LoadList，而不是使用obj.addLoad，避免记录Load对象
    Load_Hanger = obj.replaceHangerByForce(X_Hanger,Pz_Hanger);
    Load_StayedCable = obj.replaceStayedCableByForce(X_StayedCable,Pz_StayedCable);
%     Load_CableForce = obj.replaceCableByForce(X_Hanger,Pz_Hanger);
    Load_CableForce = [];
    obj.LoadList = [Load_Hanger,Load_StayedCable,Load_CableForce];
    
end