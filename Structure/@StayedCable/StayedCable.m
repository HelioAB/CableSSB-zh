classdef StayedCable < Structure
    properties
        InternalForce
        UnstressedLength
        Strain
    end
    % StayedCable对象推荐在RigidBeam对象建立之后建立
    methods
        function obj = StayedCable(IPoint,JPoint,section,material,options)
            arguments
                IPoint (1,:) = Point.empty
                JPoint  (1,:) {mustBeEqualSize(IPoint,JPoint)} = Point.empty
                section = Section('StayedCable')
                material = Material('StayedCable')
                options.IStructure {mustBeA(options.IStructure,'Structure')} = Structure.empty
                options.JStructure {mustBeA(options.JStructure,'Structure')} = Structure.empty
            end
            obj = obj@Structure(section,material);

            if ~isempty(IPoint)
                obj.Line = Line([],IPoint,JPoint);
                uni_point = unique([IPoint,JPoint]);
                newpoint = uni_point.findUnrecord();
                obj.NewPoint = newpoint;
                obj.NewLine = obj.Line;
                if ~isempty(options.IStructure)
                    obj.addConnectPoint(IPoint,options.IStructure)
                    options.IStructure.addConnectPoint(IPoint,obj)
                else
                    obj.addConnectPoint(IPoint)
                end
                if ~isempty(options.JStructure)
                    obj.addConnectPoint(JPoint,options.JStructure)
                    options.JStructure.addConnectPoint(JPoint,obj)
                else
                    obj.addConnectPoint(JPoint)
                end
            end
        end
        function element_type = setElementType(obj,val)
            if isa(val,'Link10')
                element_type = val;
            else
                error('StayedCable结构的Element Type必须为Link10')
            end
        end 
        [dir_tower_tension,sign_tower_tension] = getStayedCableTensionDirectionAtTower(obj)
        [P_tower_x,P_tower_y,P_tower_z,P_girder_x,P_girder_y,P_girder_z] = getP(obj,P_girder_z)
        strain = getStrain(obj)
        unstressed_length = getUnstressedLengthByForce(obj,P_tower_z)
        tower_point = findTowerPoint(obj)
        girder_point = findGirderPoint(obj)
        Vertical_Force = getVerticalForce(obj)
        [LineList,X,RowIndex,ColumnIndex] = getSameGirderXLine(obj)
    end
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end