function [half_bridge,girder,tower,cable,stayedcable,hanger,rigidbeam,couplings,constraints] = getHalfBridge(obj,options)
    arguments
        obj
        options.Pattern {mustBeMember(options.Pattern,{'Element','Line'})} = 'Element'
    end
    half_bridge = [];
    girder = [];
    tower = [];
    cable = [];
    stayedcable = [];
    hanger = [];
    rigidbeam = [];
    structures = obj.StructureList;
    % 输出一半桥梁的Line对象或Element对象
    if length(obj.StructureCell_MainSpan)>1
        error('暂不支持多个MainSpan的情况')
    end
    girder_mainspan = findStructureObjsByClassInCell(obj.StructureCell_MainSpan,'Girder');
    if length(girder_mainspan)>1
        error('暂不支持主跨有多个Girder对象的情况')
    end
    coord_middle_MainSpan = girder_mainspan.PointCenter.Coord();
    for i=1:length(structures)
        structure = structures{i};
        switch options.Pattern
            case 'Element'
                lines_structure = structure.Element;
            case 'Line'
                lines_structure = structure.Line;
        end
        coord_lines_center = lines_structure.getCenterPointCoord();
        X_lines_center = coord_lines_center(:,1)';
        lines_halfbridge = lines_structure(X_lines_center <= coord_middle_MainSpan(1));
        half_bridge = [half_bridge,lines_halfbridge];
        class_structure = class(structure);
        switch class_structure
            case 'Girder'
                girder = [girder,lines_halfbridge];
            case 'Tower'
                tower = [tower,lines_halfbridge];
            case 'Cable'
                cable = [cable,lines_halfbridge];
            case 'StayedCable'
                stayedcable = [stayedcable,lines_halfbridge];
            case 'Hanger'
                hanger = [hanger,lines_halfbridge];
            case 'RigidBeam'
                rigidbeam = [rigidbeam,lines_halfbridge];
        end
    end
    % 输出Couplings
    couplings = [];
    all_couplings = obj.CouplingList;
    for i=1:length(all_couplings)
        coupling = all_couplings{i};
        coord_coupling = coupling.MasterPoint.Coord();
        if coord_coupling(1) <= coord_middle_MainSpan(1)
            couplings = [couplings,coupling];
        end
    end
    % 输出Constraints
    constraints = [];
    all_constraints = obj.ConstraintList;
    for i=1:length(all_constraints)
        constraint = all_constraints{i};
        coord_constraint = constraint.Point.Coord();
        if coord_constraint(1) <= coord_middle_MainSpan(1)
            constraints = [constraints,constraint];
        end
    end
end
function structureobjs = findStructureObjsByClassInCell(StructureCell,name_class)
    structureobjs = [];
    structures = StructureCell{1};
    for i=1:length(structures)
        if isa(structures{i},name_class)
            structureobjs = [structureobjs,structures{i}];
        end
    end
end