classdef FiniteElementModel < handle
    properties
        BridgeModel % 如果要查找，可以使用BridgeModel属性的相关成员方法
        Node % NodeList和ElementList均按照BridgeModel.StructureList的顺序排列，存储
        Element
        StiffnessMatrix
        RHS
        Maps % 一个struct数据，其中存储了所有的Map数据
    end
    properties(Hidden)
        TempResult
    end
    methods
        function obj = FiniteElementModel(BridgeModel,Nodes,Elements,Maps)
            arguments
                BridgeModel {mustBeA(BridgeModel,'Bridge')}
                Nodes {mustBeA(Nodes,'Node')}
                Elements {mustBeA(Elements,'Element')}
                Maps {mustBeA(Maps,'struct')}
            end
            obj.BridgeModel = BridgeModel;
            obj.Node = Nodes;
            obj.Maps = Maps;
            % 赋予Element对象Section、Material、ElementType属性
            StructureList = BridgeModel.StructureList; 
            Map_Element = Maps.Element;
            Line2Element = Maps.Line2Element;
            for i=1:length(StructureList)
                structure = StructureList{i};
                line = structure.Line;
                num_line = [line.Num];
                for j=1:length(num_line)
                    num_elements = Line2Element(num_line(j));
                    for k=1:length(num_elements)
                        element = Map_Element(num_elements(k));
                        element.Section = structure.Section(j);
                        element.Material = structure.Material;
                        element.ElementType = structure.ElementType;
                    end
                end
            end
            obj.Element = Elements;
            obj.TempResult = struct;% 仅在新建FiniteElementModel时需要重置obj.TempResult
        end
        NaN_Node = checkNaNDisplacement(obj,ElementArray)
        NaN_Node = computeDisplacement(obj) % 计算Ansys导出[K]{u}={RHS}
        NaN_Node = completeDisplacement(obj) % 补全因为Constraint和Coupling而消去的位移

        new_obj = clone(obj)
        
        
        ElementArray = getElementByStructure(obj,StructureList)
        NodeArray = getNodeByStructure(obj,StructureList)

        % 可视化
        [fig,ax] = plot(obj)
        plotBendingMoment(obj,options)

    end
    methods(Static,Hidden)% 测试函数
        test_PointForceVSNodeForce 
    end
end