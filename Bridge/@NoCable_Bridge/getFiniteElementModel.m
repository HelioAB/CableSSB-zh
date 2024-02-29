function [FEModel,isEquationCompleted] = getFiniteElementModel(obj)
    % 显示进度
    disp('Is getting Finite Element Model from ANSYS...')
    % 获取有限元模型，并将之存储到obj.FiniteElementModel中
    obj.FiniteElementModel = obj.OutputMethod.getFiniteElementModel; % 将obj导出到Ansys中并提取总体刚度矩阵、RHS、单元刚度矩阵等数据，这些数据已转换为Matlab易读取的格式
    obj.FiniteElementModel.computeDisplacement; % 求解整体坐标系下的节点位移
    obj.FiniteElementModel.completeDisplacement;% 补全因Constraint、Coupling而删去的方程
    NaN_node = obj.FiniteElementModel.checkNaNDisplacement;% 检查是否已经补全了所有的方程
    isEquationCompleted = ~length(NaN_node); % 如果NaN_node为空，代表没有未补全的方程，即方程没有被补齐
    FEModel = obj.FiniteElementModel;
end