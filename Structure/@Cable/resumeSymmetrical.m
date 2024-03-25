function RelatedObj = resumeSymmetrical(obj) 
    % 恢复对称关系：这里只恢复关于XOZ平面对称的关系
    %   1. 对称节点力
    %   2. 重新找形
    if ~isfield(obj.RelatedToStructure,'Relation')
    elseif strcmp(obj.RelatedToStructure.Relation,'Symmetrizing To') % 只有当obj与obj.RelatedToStructure.RelatedStructure之间是对称关系时
        vector = obj.RelatedToStructure.RelationData.PlaneOfSymmetry;
        normal_vector = vector/norm(vector);
        if ~all(normal_vector==[0,1,0])
            error('只恢复关于XOZ平面对称的关系')
        end
        RelatedObj = obj.RelatedToStructure.RelatedStructure;
        % 1. 对称节点力
        RelatedObj.Params = obj.Params;
        RelatedObj.Params.coord_A = RelatedObj.PointA.Coord;
        RelatedObj.Params.coord_B = RelatedObj.PointB.Coord;
        RelatedObj.Params.P_force_y = -obj.Params.P_force_y;
        RelatedObj.Params.P_y = -obj.Params.P_y;

        % 2. 复制对象的找形
        RelatedObj.findShape(RelatedObj.Params.P_x,RelatedObj.Params.P_y,RelatedObj.Params.P_z);
    end
    
end