function Output  = findShape(obj,P_x,P_y,P_z)
    % P_x, P_y, P_z:作用在主缆每个节点上的力，方向为全局坐标方向，向量长度为去除两端点的
    arguments
        obj
        P_x (1,:) {mustBeNumeric}  = zeros(1,length(obj.Point)-2)
        P_y (1,:) {mustBeNumeric,mustBeEqualSize(P_x,P_y)} = zeros(1,length(obj.Point)-2)
        P_z (1,:) {mustBeNumeric,mustBeEqualSize(P_x,P_z)} = zeros(1,length(obj.Point)-2)
    end
                
    % 材料和截面参数
    section = obj.Section(1);
    material = obj.Material;
    if ~isempty(section) && ~isempty(material)
        A = section.SectionData.Area; % 主缆截面积
        q = A * material.MaterialData.gamma; % 主缆自重
        E = material.MaterialData.E; % 弹模
        obj.Params.A = A;
        obj.Params.q = q;
        obj.Params.E = E;
    end
    
    % 执行找形程序
    if ~isempty(obj.Algo_ShapeFinding)
        % 这里的P_x,P_y,P_z都是作用在cable上的施力，坐标满足整体坐标系
        Output = obj.Algo_ShapeFinding.action(obj.Params,P_x,P_y,P_z);
        obj.Point.edit('X',Output.X)
        obj.Point.edit('Y',Output.Y)
        obj.Point.edit('Z',Output.Z)
    else
        error('还没有指定Algo_ShapeFinding属性，无法进行缆索找形')
    end

    % 提取出无应力长度和应变
    obj.Result_ShapeFinding = Output;
    obj.UnstressedLength = Output.UnstressedLength;
    obj.Strain = Output.Strain;
end
function mustBeEqualSize(a,b)
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = '输入值必须有相同的size。';
        throwAsCaller(MException(eid,msg))
    end
end