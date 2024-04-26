classdef Bridge < handle
    properties
        MaterialList
        SectionList
        ElementTypeList
        ElementDivisionList
        StructureList
        CouplingList
        ConstraintList
        LoadList
        OutputMethod
        InputMethod
        InfluenceLine = struct
        Params = struct
        Information = struct
    end
    methods
        function obj = Bridge()
            obj.MaterialList = {};
            obj.SectionList = {};
            obj.ElementTypeList = {};
            obj.ElementDivisionList = {};
            obj.StructureList = {};
            obj.CouplingList = {};
            obj.ConstraintList = {};
            obj.LoadList = {};
            obj.OutputMethod = [];
            obj.InputMethod = struct;
        end
        build(obj)
        tf = isempty(obj)
        %% plot画图相关
        plotCoupling(obj,fig,ax)
        plotContraint(obj,fig,ax)
        plotLoad(obj,fig,ax,scale)
        [fig,ax] = plotStructure(obj,fig,ax,options)
        [fig,ax] = plot(obj,options)
        %% 
        addToList(obj,ListClassName,value)
        updateList(obj,ListName,Value)
        %% Name相关
        % 编辑Structure的Name
        editStructureName(obj,StructureObj,Name)
        % 通过各种信息寻找
        [obj_list,index]        = findObjListByName(obj,ListClassName,Name)
        [structure_list,index]  = findStructureByName(obj,StructureName)
        [section_list,index]    = findSectionByName(obj,SectionName)
        [material_list,index]   = findMaterialByName(obj,MaterialName)
        [material_list,index]   = findElementTypeByName(obj,ElementTypeName)
        [coupling_list,index]   = findCouplingByName(obj,CouplingName)
        [constraint_list,index] = findConstraintByName(obj,ConstraintName)
        [load_list,index]       = findLoadByName(obj,LoadName)
        [searched_structure,index,index_inner] = findStructureByInfo(obj,Info)
        [structure_list,index]  = findStructureByClass(obj,StructureClass)
        [constraint_list,index] = findConstraintByStructure(obj,StructureList)
        [coupling_list,index,coupling_master_list,coupling_slave_list] = findCouplingByStructure(obj,StructureList)
        % 获取Bridge中某个List中所有元素的Name
        name = getName(obj,ListClassName)
        % 输出
        output(obj,options)
        
        % 其他
        weight = getGirderWeight(obj,GirderList)
        setForceTo(obj,StructureCell,P_Bottom_Z)
        count = getLineCountOfClass(obj,StructureClass)
        [AppliedPoints,XForce,YForce,ZForce] = getConcentratedForceInfo(obj)
        elems_beam = getAllBeams(obj)
        elems_link = getAllLinks(obj)
        nodes = getAllNodes(obj)
        %clone
        new_bridge = clone(obj)

    end
    methods
        % build各种Structure对象
        girder = buildGirder(obj,CoordA,CoordB,L,section,material,element_type,division_num,options)
        girder = buildGirderByInput(obj,InputMethod,functionhandle_findRefPoint,Coord_MoveTo,section,material,element_type,division_num,options)
        tower = buildTower(obj,CoordBottom,CoordTop,L,section,material,element_type,division_num,options)
        tower = buildTowerByInput(obj,InputMethod,functionhandle_findRefPoint,Coord_MoveTo,section,material,element_type,division_num,options)
        pier = buildPier(obj,CoordBottom,CoordTop,L,section,material,element_type,division_num,options)
        pier = buildPierByInput(obj,InputMethod,functionhandle_findRefPoint,Coord_MoveTo,section,material,element_type,division_num,options)
        
        rigid_beam = buildRigidBeam(obj,IPoint,JPoint,IStructure,JStructure,section,material,element_type,division_num,options)
        rigid_beam = buildRigidBeamByOffset(obj,FromPoint,FromStructure,Offset,section,material,element_type,division_num,options)

        [cable,Output] = buildMainSpanCable(obj,CoordA,CoordB,L,index_hanger,P_h_x,P_h_y,P_h_z,hOm,section,material,element_type,division_num,Algo_ShapeFinding,options)
        [cable,Output] = buildSideSpanCable(obj,CoordA,CoordB,L,index_hanger,P_h_x,P_h_y,P_h_z,F_x,section,material,element_type,division_num,Algo_ShapeFinding,options)
        symm_cable = symmetrizeCable(obj,cable,symmetry_point,symmetry_vector,options)


        hanger = buildHanger(obj,IPoint,JPoint,IStructure,JStructure,section,material,element_type,division_num,options)
        stayedcable = buildStayedCable(obj,IPoint,JPoint,IStructure,JStructure,section,material,element_type,division_num,options)

        coupling = addCoupling(obj,MasterPoint,SlavePoint,DoF,options)
        constraint = addConstraint(obj,ConstraintPoint,DoF,Value,options)
        addLoad(obj,load,options)
        [status,cmdout] = run(obj,options)
    end
end