classdef Element < DataRecord
    properties
        INode
        JNode
        KNode
        StiffnessMatrix_GlobalCoord = zeros(12,12)
        Force_GlobalCoord = nan(12,1) % 存储IJ节点力结果（Fx, Fy, Fz, Mx, My, Mz），整体坐标系下。如果还没有被计算出来，就是NaN向量
        Section
        Material
        ElementType
    end
    properties(Dependent)
        Displacement_GlobalCoord % 由IJ节点的位移决定
    end
    properties(Hidden,Access=private)
        % 存储已经计算过的局部坐标系系的单元刚度矩阵、位移、力、坐标变换矩阵
        % 初始为空，当被计算过一次之后，下面这些private属性会存储对应的计算值。下一次调用接口直接使用存储值，不需要重新计算
        % 这些private属性与外界的接口 见注释
        % 以下这些情况会令下面这些private属性进行重新计算（获取Node对象的通知）
        %   1. INode和JNode的坐标变化，使得StiffnessMatrix、Displacement、Force、TransformMatrix变化(未实现)
        %   2. INode和JNode的位移变化，使得Displacement、Force变化
        StiffnessMatrix = []% 接口：StiffnessMatrix_LocalCoord(obj)
        TransformMatrix = []% 接口：TransformMatrix_Global2Local(obj)
    end
    methods
        function obj = Element(Num,INode,JNode,KNode)
            arguments
                Num = []
                INode = []
                JNode = []
                KNode = []
            end
            obj = obj@DataRecord()
            if nargin ~= 0
                % 参数验证
                mustBeInteger(Num);
                mustBePositive(Num);
                if ~isempty(KNode)
                    mustBeA(INode,'Node')
                    mustBeA(JNode,'Node')
                    mustBeA(KNode,'Node')
                    mustBeEqualSize(INode,JNode)
                    mustBeEqualSize(INode,KNode)
                    len = length(INode);
                    if ~isempty(Num)
                        mustBeEqualSize(INode,Num)
                    else
                        Num = Element.MaxNum()+[1:len];
                    end
                    % 创建对象数组
                    obj(1,len) = Element();
                    for i = 1:len
                        obj(1,i).Num = Num(1,i);
                        obj(1,i).INode = INode(1,i);
                        obj(1,i).JNode = JNode(1,i);
                        obj(1,i).KNode = KNode(1,i);
                    end
                else
                    mustBeA(INode,'Node')
                    mustBeA(JNode,'Node')
                    mustBeEqualSize(INode,JNode)
                    len = length(INode);
                    if ~isempty(Num)
                        mustBeEqualSize(INode,Num)
                    else
                        Num = Element.MaxNum()+[1:len];
                    end
                    % 创建对象数组
                    obj(1,len) = Element();
                    for i = 1:len
                        obj(1,i).Num = Num(1,i);
                        obj(1,i).INode = INode(1,i);
                        obj(1,i).JNode = JNode(1,i);
                    end
                end                
            else
                obj.Num = [];
                obj.INode = [];
                obj.JNode = [];
                obj.KNode = [];
            end
        end
        
        function val = get.Displacement_GlobalCoord(obj)
            val = [obj.INode.Displacement_GlobalCoord;obj.JNode.Displacement_GlobalCoord];
        end
        function node = Node(obj)
            IJNode = [[obj.INode],[obj.JNode]];
            node = IJNode.unique;
        end
        function matrix = StiffnessMatrix_LocalCoord(obj)
            if isempty(obj.StiffnessMatrix) % obj.StiffnessMatrix为空时才进行一次计算
                T = obj.TransformMatrix_Global2Local;
                matrix = T*obj.StiffnessMatrix_GlobalCoord*T';
                obj.StiffnessMatrix = matrix;
            else % 否则使用存储值
                matrix = obj.StiffnessMatrix;
            end
        end
        function vector = Displacement_LocalCoord(obj)
            T = obj.TransformMatrix_Global2Local;
            vector = T*obj.Displacement_GlobalCoord;
        end
        function vector = Force_LocalCoord(obj)
            T = obj.TransformMatrix_Global2Local;
            vector = T * obj.StiffnessMatrix_GlobalCoord * obj.Displacement_GlobalCoord;
        end
        function converted_vector = AnsysForceResult(obj)
            T = obj.TransformMatrix_Global2Local;
            stiffness_matrix = obj.StiffnessMatrix_GlobalCoord;
            vector =  T * stiffness_matrix * obj.Displacement_GlobalCoord;
            converted_vector = [1,1,-1,1,1,-1,-1,-1,1,-1,-1,1]'.*vector;
            % 为什么要转换见：https://www.yuque.com/helios-library/qzyh8p/gfo3z59yrv9hymbu/edit?toc_node_uuid=8-1dC90ACEAr-FFx
        end
        line_handle = plot(obj,options)
        BendingStraintEnergy = getBendingStrainEnergy(obj)
        T = TransformMatrix_Global2Local(obj) % 坐标变换矩阵， T: Global_Coord -> Local_Coord
        len = ElementLength(obj) % 单元长度
        [delta_x,delta_y,delta_z] = DeltaLength(obj) % IJ节点的坐标差分
        [Norm_x,Norm_y,Norm_z] = getLocalCoordSystem(obj,tol) % 单元坐标系x、y、z在整体坐标系下的方向向量
        [Comp_x,Comp_y,Comp_z] = getLocalCoordSystemComponent(obj,GlobalDirection,tol) % 给定一个大小和方向direction（1*3数值向量），获得在单元坐标系的各个分量
        coord_centerpoint = getCenterPointCoord(obj)
        sorted_elems = sortByCenterPoint(obj,Direction)
    end
    methods(Static)
        function collection = Collection()
            persistent Data
            if isempty(Data)
                Data = ElementCollection();
            end
            collection = Data;
        end
        function element_list = ElementList()
            element_list = Element.Collection.ObjList;
        end
        function element_map = Map()
            element_map = Element.Collection.Map;
        end
        function element_table = Table()
            element_table = Element.Collection.Table;
        end
        function update(PropertyName,ChangeTo)
            Element.Collection.updateObjList(PropertyName,ChangeTo)
        end
        function Obj = getElementByNum(Num)
            arguments
                Num (1,1) {mustBeInteger}
            end
            Obj = Element.Collection.getObj('Num',Num); % 必须时经过record之后的Element对象
        end
        function max_num = MaxNum(obj)
            if nargin==0
                element_list = Element.ElementList;
                if ~isempty(element_list)
                    num = [element_list.Num];
                else
                    num = [];
                end
            else
                unsorted_num = [obj.Num];
                num = sort(unsorted_num);
            end
            if isempty(num)
                max_num = 0;
            else
                max_num = max(num);
            end
        end
    end

    methods(Static,Hidden)% 用于测试的函数，用于测试的函数在函数名以test开头,后面的编号或名字随意
        test_01()
    end
end