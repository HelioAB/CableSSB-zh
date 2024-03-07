classdef Hanger < Structure
    properties
        IPoint
        JPoint
        InternalForce
        UnstressedLength
        Strain
    end
    % Hanger对象推荐在RigidBeam对象建立之后建立
    methods
        function obj = Hanger(IPoint,JPoint,section,material,options)
            arguments 
                IPoint (1,:) {mustBeA(IPoint,'Point')} = Point.empty
                JPoint (1,:) {mustBeA(JPoint,'Point'),mustBeEqualSize(IPoint,JPoint)} = Point.empty
                section = Section('Hanger')
                material = Material('Hanger')
                options.IStructure {mustBeA(options.IStructure,'Structure')} = Structure.empty
                options.JStructure {mustBeA(options.JStructure,'Structure')} = Structure.empty
            end
            obj = obj@Structure(section,material);

            if ~isempty(IPoint) && ~isempty(JPoint)
                obj.IPoint = IPoint;
                obj.JPoint = JPoint;
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
                error('Hanger结构的Element Type必须为Link10')
            end
        end
        
        [dir_cable_tension,sign_cable_tension] = getHangerTensionDirectionAtCable(obj)
        [P_cable_x,P_cable_y,P_cable_z,P_girder_x,P_girder_y,P_girder_z] = getP(obj,P_girder_z)
        strain = getStrain(obj)
        point_list = findCablePoint(obj)
        point_list = findGirderPoint(obj)
        unstressed_length = getUnstressedLengthByForce(obj,P_cable_z)
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