classdef RigidBeam < Structure
    methods
        function obj = RigidBeam(IPoint,JPoint,section,material,options)
            arguments
                IPoint (1,:) 
                JPoint  (1,:) {mustBeEqualSize(IPoint,JPoint)}
                section = Section('Hanger')
                material = Material('Hanger')
                options.IStructure {mustBeA(options.IStructure,'Structure')} = Structure.empty % IPoint所在的Structure对象
                options.JStructure {mustBeA(options.JStructure,'Structure')} = Structure.empty
            end
            obj = obj@Structure(section,material);

            if ~isempty(IPoint)
                obj.Line = Line([],IPoint,JPoint);
                uni_point = unique([IPoint,JPoint]);
                newpoint = uni_point.findUnrecord();
                obj.NewPoint = newpoint;
                obj.NewLine = obj.Line;
                if ~isempty(options.IStructure) % IPoint所在的Structure对象为IStructure，所以obj.ConnectPoint()
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
        points = findGirderPoint(obj)
    end
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end