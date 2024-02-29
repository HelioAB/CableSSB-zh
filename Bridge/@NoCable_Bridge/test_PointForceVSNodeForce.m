% clear all
% clc
% % 全桥模型
% b = CableStayedSuspension_Bridge;
% b.build
% output_method = OutputToAnsys(b,"JobName",'TotalModel',...
%     'WorkPath','C:\Users\Huawei\Desktop\test\01 Total Model',...
%     'MacFilePath','C:\Users\Huawei\Desktop\test\01 Total Model\main.mac',...
%     'ResultFilePath','C:\Users\Huawei\Desktop\test\01 Total Model\findState\result.out');
% b.OutputMethod = output_method;
% % b.plot
% b.output
% format default

% 去掉缆索模型
% bridge_state = NoCable_Bridge(b);
% bridge_state.build
% output_method = OutputToAnsys(bridge_state,"JobName",'NonCableModel',...
%     'WorkPath','C:\Users\Huawei\Desktop\test\00 Test',...
%     'MacFilePath','C:\Users\Huawei\Desktop\test\00 Test\main.mac',...
%     'ResultFilePath','C:\Users\Huawei\Desktop\test\00 Test\result.out');
% bridge_state.OutputMethod = output_method;
[FEModel,isEquationCompleted] = bridge_state.getFiniteElementModel;


% 检查所有Load对象作用荷载和Equation之间的关系
[AppliedPoints,XPointForce,YPointForce,ZPointForce] = bridge_state.getConcentratedForcecInfo;
num_points = [AppliedPoints.Num];

Point2Node = FEModel.Maps.Point2Node;
Node2DoFEquation = FEModel.Maps.Node2DoFEquation;
RHS = FEModel.RHS;

num_nodes = zeros(1,length(num_points));
XNodeForce = zeros(1,length(num_points));
YNodeForce = zeros(1,length(num_points));
ZNodeForce = zeros(1,length(num_points));

for i=1:length(num_points)
    num_nodes(i) = Point2Node(num_points(i));
    row_equation = Node2DoFEquation(num_nodes(i));
    if row_equation(1)==0
    else
        XNodeForce(i) = RHS(row_equation(1));
    end
    if row_equation(2)==0
    else
        YNodeForce(i) = RHS(row_equation(2));
    end
    if row_equation(3)==0
    else
        ZNodeForce(i) = RHS(row_equation(3));
    end
end
max(abs(XPointForce - XNodeForce))

max(abs(YPointForce - YNodeForce))

max(abs(ZPointForce - ZNodeForce))