function FE_model = getFiniteElementModel(obj)
    obj.outputElementType;
    obj.outputMaterial;
    obj.outputSection;
    obj.outputReal;
    obj.outputKeyPoint;
    obj.outputLine;
    obj.outputLineAttribution;
    obj.outputLineMesh;
    obj.outputConstraint;
    obj.outputLoad;
    obj.outputCoupling;
    obj.outputSolve('wrfull',1);
    
    % 需求：导出 节点编号及其坐标
    % 需求：导出 单元编号及其IJ节点编号
    % 需求：导出 KeyPoint -> Node的映射
    % 需求：导出 总刚、RHS
    % 需求：导出 .mapping文件
    % 需求：导出 局部坐标系下的单刚、作用力向量
    [Main_file,ElementStiffness_file] = outputMain(obj);
    Node_file = getNode(obj);
    Element_file = getElement(obj);
    KeyPoint2Node_file = getKeyPoint2Node(obj);
    [GlobalStiffness_file,GlobalStiffness_mapping_file] = getGlobalStiffness(obj);

    % 运行APDL，使得上以上的导出需求能够被Ansys执行
    deleteFile([obj.JobName,'.lock'],obj.WorkPath); % 删除了.lock文件，本次运行的结果才会覆盖上次运行的结果
    obj.runMac;

    % 在工作路径下新建文件夹Info，将所有需要的信息都装到这个文件夹中
    % 忽略"文件已经存在"的警告信息
    Info_folder = [obj.WorkPath,'\Info'];
    try
        [status,msg,msgID] = mkdir(Info_folder);
    catch ME
        switch ME.identifier
            case 'MATLAB:MKDIR:DirectoryExists'
            otherwise
                rethrow(ME)
        end
    end

    % 将文件移动到Info文件夹
    movefile(Node_file,Info_folder)
    movefile(Element_file,Info_folder)
    movefile(KeyPoint2Node_file,Info_folder)
    movefile(ElementStiffness_file,Info_folder)
    movefile(GlobalStiffness_file,Info_folder)
    movefile(GlobalStiffness_mapping_file,Info_folder)

    % 更新文件位置
    Node_file = FilePathAfterMove(Node_file,Info_folder); 
    Element_file = FilePathAfterMove(Element_file,Info_folder);
    KeyPoint2Node_file = FilePathAfterMove(KeyPoint2Node_file,Info_folder);
    ElementStiffness_file = FilePathAfterMove(ElementStiffness_file,Info_folder);
    GlobalStiffness_file = FilePathAfterMove(GlobalStiffness_file,Info_folder);
    GlobalStiffness_mapping_file = FilePathAfterMove(GlobalStiffness_mapping_file,Info_folder);

    % 导入的部分使用InputFrom方法
    inputNode = InputFromTXT(Node_file);
    inputElement = InputFromTXT(Element_file);
    inputKeyPoint2Node = InputFromTXT(KeyPoint2Node_file);
    inputElementStiffness = InputAnsysElementStiffnessMatrix(ElementStiffness_file);
    inputGlobalStiffness = InputAnsysGlobalStiffnessMatrix(GlobalStiffness_file);
    inputMapping = InputAnsysMapping(GlobalStiffness_mapping_file);

    % 从InputFrom中获得数据，并创建Node对象和Element对象
    inputNode.action(4); % 4列数据，所以需要输入参数4
    inputElement.action(4);
    inputKeyPoint2Node.action(2);
    inputElementStiffness.action;
    inputGlobalStiffness.action;
    inputMapping.action;
    % 建立FiniteElementModel对象
    % BridgeModel
    BridgeModel = obj.OutputObj;
    % Nodes
    Nodes = Node(inputNode.RawData(:,1)',inputNode.RawData(:,2)',inputNode.RawData(:,3)',inputNode.RawData(:,4)');
    Map_Node = Nodes.getMap;
    % Elements
    Num_INodes = inputElement.RawData(:,2)';
    Num_JNodes = inputElement.RawData(:,3)';
    Num_KNodes = inputElement.RawData(:,4)';
    INodes = Nodes.findObjByNum(Num_INodes);
    JNodes = Nodes.findObjByNum(Num_JNodes);
    KNodes = Nodes.findObjByNum(Num_KNodes); % 很可能会有编号为空的Node
    Elements = Element(inputElement.RawData(:,1)',INodes,JNodes,KNodes);
    Map_Element = Elements.getMap;
    % Point2Node、Node2Point
    % Ansys中的KeyPoint编号和Matlab中Point对象的编号相同
    Num_KeyPoints = inputKeyPoint2Node.RawData(:,1);
    Num_Nodes = inputKeyPoint2Node.RawData(:,2);
    Map_Point2Node = containers.Map('KeyType','double','ValueType','any');
    Map_Node2Point = containers.Map('KeyType','double','ValueType','any');
    for i=1:length(Num_KeyPoints)
        Map_Point2Node(Num_KeyPoints(i)) = Num_Nodes(i);
        Map_Node2Point(Num_Nodes(i)) = (Num_KeyPoints(i));
    end
    % Line2Element
    % Ansys中Line编号和Matlab中Line编号不一致
    Map_Line2Element = obj.OutputObj.Params.Map_MatlabLine2AnsysElem;
    % Element2Line
    Map_AnsysElement2MatlabLine = obj.OutputObj.Params.Map_AnsysElem2MatlabLine;
    keys_AnsysElement2MatlabLine = keys(Map_AnsysElement2MatlabLine);
    Map_Element2Line = containers.Map('KeyType','double','ValueType','any');
    for i=1:length(keys_AnsysElement2MatlabLine)
        key = keys_AnsysElement2MatlabLine{i};
        Map_Element2Line(key) = Map_AnsysElement2MatlabLine(key).Num;
    end
    % Node2Element
    Map_Node2Element = containers.Map('KeyType','double','ValueType','any');
    for i=1:length(Elements)
        element = Elements(i);
        i_node = element.INode;
        j_node = element.JNode;
        if isKey(Map_Node2Element,i_node.Num) % 如果INode的编号已经记录过了,就在后面添加
            Map_Node2Element(i_node.Num) = [Map_Node2Element(i_node.Num),element.Num];
        else % 如果INode的编号还没有被记录
            Map_Node2Element(i_node.Num) = element.Num;
        end
        if isKey(Map_Node2Element,j_node.Num)
            Map_Node2Element(j_node.Num) = [Map_Node2Element(j_node.Num),element.Num];
        else
            Map_Node2Element(j_node.Num) = element.Num;
        end
    end
    % Element Stiffness Matrix
    keys_ElementStiffness = keys(inputElementStiffness.Map_Element2StiffnessMatrix);
    for i=1:length(keys_ElementStiffness)
        key = keys_ElementStiffness{i};
        element = Map_Element(key);
        element.StiffnessMatrix_GlobalCoord = inputElementStiffness.Map_Element2StiffnessMatrix(key);
    end

    % Maps
    % Maps中的contianers.Map对象的创建和使用原则：
    %       1. 编号 -> 对象：输入编号，输出对象。DataRecord对象可以使用obj.getMap、obj.findObjByNum(NumArray)
    %       2. 对象 -> 对象：输入编号，输出编号。避免复合映射的过程中需要"提取对象编号"这一操作
    Maps = struct;
    Maps.Node = Map_Node;
    Maps.Element = Map_Element;
    Maps.Node2Point = Map_Node2Point;
    Maps.Point2Node = Map_Point2Node;
    Maps.Line2Element = Map_Line2Element;
    Maps.Element2Line = Map_Element2Line;
    Maps.Node2Element = Map_Node2Element;
    Maps.Equation2NodeDoF = inputMapping.Map_Equation2NodeDoF;
    Maps.Node2DoFEquation = inputMapping.Map_Node2DoFEquation;

    % 创建FiniteElementModel对象
    FE_model = FiniteElementModel(BridgeModel,Nodes,Elements,Maps);

    % 存储总刚、RHS
    FE_model.StiffnessMatrix = inputGlobalStiffness.StiffMatrix;
    FE_model.RHS = inputGlobalStiffness.RHS;

end

function [Main_MacFile,ElementStiffness_file] = outputMain(obj)
    output_str = ['finish $ /clear',newline,newline,...
                  '/prep7',newline,...
                  '*set,g,9.806 $ acel,,,g  !重力加速度，设为Z方向, m/s^2',newline,...
                  '/input,defElementType,mac,,,0  				!1. 定义单元类型',newline,...
                  '/input,defMaterial,mac,,,0  			    !2. 定义材料属性',newline,...
                  '/input,defSection,mac,,,0					!3. 定义截面数据',newline,...
                  '/input,defReal,mac,,,0  					!4. 定义实常数',newline,...
                  '/input,defKeyPoint,mac,,,0					!5. 定义关键点',newline,...
                  '/input,defLine,mac,,,0						!6. 定义线',newline,...
                  '/input,defLineAttribution,mac,,,0           !7. 定义Line的属性',newline,...
                  '/input,defLineMesh,mac,,0                   !8. 划分单元',newline,...
                  '/input,defConstraint,mac,,,0				!9. 定义约束',newline,...
                  '/input,defLoad,mac,,,0						!10. 定义荷载',newline,...
                  '/input,defCoupling,mac,,,0                  !11. 定义耦合',newline,...
                  sprintf('save,%s,db',obj.JobName),newline,...
                  'finish',newline,newline];
    
    % 导出 节点编号及其坐标，存储在 Node.txt
    output_str = [output_str,'/input,getNode,mac,,,0',newline];

    % 导出 单元编号及其IJ节点编号，存储在 Element.txt
    output_str = [output_str,'/input,getElement,mac,,,0',newline];

    % 导出 KeyPoint -> Node的映射，存储在 KeyPoint2Node.txt
    output_str = [output_str,'/input,getKeyPoint2Node,mac,,,0',newline];

    % 导出 Line -> Element的映射，存储在 Line2Element.txt
    output_str = [output_str,'/input,getLine2Element,mac,,,0',newline];

    % 导出 单刚和作用力向量,存储在 ElementStiffness.out
    output_str = [output_str,'/debug,-1,,,1',newline,...
                  sprintf('/output,%s,out,,','ElementStiffness'),newline,...
                  '/input,defSolve,mac,,,0                     !12. 求解选项设置与求解',newline,...
                  '/output',newline,... % 重定向到 JobName.out
                  'finish',newline];
    ElementStiffness_file = [obj.WorkPath,'\ElementStiffness.out'];

    % 导出 总刚、RHS、.mapping文件，存储在 GlobalStiffness.txt、GlobalStiffness.mapping
    output_str = [output_str,'/input,getGlobalStiffness,mac,,,0',newline];
    

    % 输出到main.mac
    obj.outputAPDL(output_str,'main.mac','w');
    Main_MacFile = [obj.WorkPath,'\main.mac'];
end
function output_file = getNode(obj)
    output_str = ['allsel',newline,...
                    '*get,MinNum_Node,node,,Num,Min',newline,...
                    '*get,MaxNum_Node,node,,Num,Max',newline,...
                    '*get,Count_Node,node,,Count',newline,...
                    '*dim,NodeInfo,array,Count_Node,4',newline,...
                    '*do,i,MinNum_Node,MaxNum_Node',newline,...
                    '   NodeInfo(i,1) = i',newline,...
                    '   NodeInfo(i,2) = NX(i)',newline,...
                    '   NodeInfo(i,3) = NY(i)',newline,...
                    '   NodeInfo(i,4) = NZ(i)',newline,...
                    '*enddo',newline,newline];
    output_str = [output_str,'*cfopen,Node,txt',newline,...
                    '*vwrite,NodeInfo(1,1),NodeInfo(1,2),NodeInfo(1,3),NodeInfo(1,4)',newline,...
                    '%%20I%%20.8e%%20.8e%%20.8e',newline,...
                    '*cfclos',newline,newline];
    obj.outputAPDL(output_str,'getNode.mac','w');
    output_file = [obj.WorkPath,'\Node.txt'];
end
function output_file = getElement(obj)
    output_str = ['allsel',newline,...
                    '*get,MinNum_Elem,Elem,,Num,Min',newline,...
                    '*get,MaxNum_Elem,Elem,,Num,Max',newline,...
                    '*get,Count_Elem,Elem,,Count',newline,...
                    '*dim,ElementInfo,array,Count_Elem,4',newline,...
                    '*do,i,MinNum_Elem,MaxNum_Elem',newline,...
                        'ElementInfo(i,1) = i',newline,...
                        'ElementInfo(i,2) = NELEM(i,1)',newline,...% I节点
                        'ElementInfo(i,3) = NELEM(i,2)',newline,...% J节点
                        'ElementInfo(i,4) = NELEM(i,3)',newline,...% K节点，即指定单元方向的节点，如果没在LATT指定K节点，这个编号就是0
                    '*enddo',newline,newline];
    output_str = [output_str,'*cfopen,Element,txt',newline,...
                    '*vwrite,ElementInfo(1,1),ElementInfo(1,2),ElementInfo(1,3),ElementInfo(1,4)',newline,...
                    '%%20I%%20I%%20I%%20I',newline,...
                    '*cfclos',newline,newline];
    obj.outputAPDL(output_str,'getElement.mac','w');
    output_file = [obj.WorkPath,'\Element.txt'];
end
function output_file = getKeyPoint2Node(obj)
    NumList = AllPointsNum(obj);
    len_NumList = length(NumList);
    output_str = obj.outputArray(NumList,'KeyPointNum');

    output_str = [output_str,sprintf('*dim,KeyPoint2NodeInfo,array,%d,2',len_NumList),newline,...
                             sprintf('*do,i,1,%d',len_NumList),newline,...
                                '   Num_KP = KeyPointNum(i)',newline,...
                                '   KeyPoint2NodeInfo(i,1) = Num_KP',newline,...
                                '   ksel,s,,,Num_KP',newline,...
                                '   nslk,s,',newline,...
                                '   *get,KeyPoint2NodeInfo(i,2),node,0,Num,Min',newline,...
                                '*enddo',newline,newline];
    output_str = [output_str,'*cfopen,KeyPoint2Node,txt',newline,...
                    '*vwrite,KeyPoint2NodeInfo(1,1),KeyPoint2NodeInfo(1,2)',newline,...
                    '%%20I%%20I',newline,...
                    '*cfclos',newline,newline];
    obj.outputAPDL(output_str,'getKeyPoint2Node.mac','w');
    output_file = [obj.WorkPath,'\KeyPoint2Node.txt'];
end
function [output_file,mapping_file] = getGlobalStiffness(obj)
    output_str = ['/aux2',newline,...
                  sprintf('file,%s,full',obj.JobName),newline,...
                  'hbmat,GlobalStiffness,txt,,ascii,stiffness,yes,yes',newline,...
                  'finish',newline];
    obj.outputAPDL(output_str,'getGlobalStiffness.mac','w');
    output_file = [obj.WorkPath,'\GlobalStiffness.txt'];
    mapping_file = [obj.WorkPath,'\GlobalStiffness.mapping'];
end
function deleteFile(filename,folder)
    % 删除在folder文件夹下的filename文件
    filepath = fullfile(folder, filename);
    if exist(filepath, 'file')
        delete(filepath);
    end
end
function NumList = AllPointsNum(obj) % 输出Bridge对象的所有Point对象编号（不重复）
    bridge = obj.OutputObj;
    structure_list = bridge.StructureList;
    PointList = [];
    for i=1:length(structure_list)
        structure = structure_list{i};
        PointList = [PointList,structure.Point];
    end
    unique_PointList = PointList.unique;
    NumList = [unique_PointList.Num];
end
function file_path = FilePathAfterMove(original_file_path,move_to_file)
    splitted_file_path = split(original_file_path,'\');
    file = splitted_file_path{end};
    file_path = [move_to_file,'\',file];
end
%% 要点
% 1. 如果不删除.lock文件，就不能将之前计算的结果覆盖
% 2. HBMAT命令不能使用Distributed Computing生成的.full文件，只能使用Sharing-Memory Processor
% 3. 注意要在defSolve.mac中设置 wrfull,N 命令
%       1.1. 该命令放在 solve 命令之前，N表示从第N个荷载步开始就跳过分析，并把.full文件写出
%       1.2. 如果不使用 wrfull 命令，会导致通过 Ansys Batch 运行结果的 .full文件是空的，也就不能输出总刚