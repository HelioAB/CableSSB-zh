function setForceTo(obj,StructureCell,P_Bottom_Z)
    arguments
        obj
        StructureCell {mustBeA(StructureCell,'cell')} % Hanger对象或StayedCable对象组成的cell
        P_Bottom_Z {mustBeEqualSize(StructureCell,P_Bottom_Z)} % Hanger对象或StayedCable对象在下端点的Z方向受力（注意：受力而不是施力）
        % P_Bottom_Z:
        %   向量长度与StructureCell相同，必须是cell或数值向量；
        %   cell{i}为StructureCell{i}.getP的输入参数，cell{i}为数值向量,cell{i}的长度可为1，也可为StructureCell{i}.Line的长度
    end
    if isnumeric(P_Bottom_Z)
        P_Bottom_Z = num2cell(P_Bottom_Z);
    end
    for i=1:length(StructureCell)
        structure = StructureCell{i};
        mustBeA(structure,{'Hanger','StayedCable'})
        structure.getP(P_Bottom_Z{i});
    end
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end