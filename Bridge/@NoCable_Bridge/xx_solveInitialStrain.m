function xx_solveInitialStrain(obj,OutputMethod)
    arguments
        obj
        OutputMethod {mustBeA(OutputMethod,'OutputToAnsys')} = obj.OriginalBridge.OutputMethod;
    end

    % 1. 获得理想中的合理成桥状态
    ReasonableStateBridge = obj.OriginalBridge;
    OriginalOutputMethod = ReasonableStateBridge.OutputMethod;
    ReasonableStateBridge.OutputMethod = OutputMethod; % 更换OutputMethod
    ReasonableStateBridge.output;
    ReasonableStateBridge.run;

    % 3. 提取索力的.mac文件
    MatlabLine2AnsysElem = ReasonableStateBridge.Params.Map_MatlabLine2AnsysElem;
%     MatlabLine2AnsysLine = ReasonableStateBridge.Params.Map_MatlabLine2AnsysLine;
    StayedCables = obj.ReplacedStayedCable;
    Hangers = obj.ReplacedHanger;

%     % 控制Ansys输出轴力
%     str_OutputAxialForce = extractAxialForceByElem(obj,Num_AnsysElem);
%     file_OutputAxialForce = 'outputAxialForce.mac';
%     ReasonableStateBridge.OutputMethod.outputAPDL(str_OutputAxialForce,file_OutputAxialForce,'w')
%     % 输出目标索力
%     str_Strain = join(string(num2str(Strain','%.6e')),newline);
%     file_Strain = 'ObjectiveStrain.txt';
%     ReasonableStateBridge.OutputMethod.outputAPDL(str_Strain,file_Strain,'w')

    [LineList,X,RowIndex,ColumnIndex] = StayedCables.getSameGirderXLine;
    StayedCableRelation = struct('Structures',StayedCables,'LineList',{LineList},'X',X,'RowIndex',{RowIndex},'ColumnIndex',{ColumnIndex});
    
    [RealNum_StayedCable,Area_StayedCable] = redistributeRealNumAndArea(StayedCableRelation);
    StayedCableRelation.RealNum = RealNum_StayedCable;
    StayedCableRelation.Area = Area_StayedCable;
    Strain_Control_StayedCable = getControlStrain(StayedCableRelation);

    [LineList,X,RowIndex,ColumnIndex] = Hangers.getSameGirderXLine;
    HangerRelation = struct('Structures',Hangers,'LineList',{LineList},'X',X,'RowIndex',{RowIndex},'ColumnIndex',{ColumnIndex});
    [RealNum_Hanger,Area_Hanger] = redistributeRealNumAndArea(HangerRelation);
    HangerRelation.RealNum = RealNum_Hanger;
    HangerRelation.Area = Area_Hanger;
    Strain_Control_Hanger = getControlStrain(HangerRelation);
    Strain_Control = [Strain_Control_StayedCable,Strain_Control_Hanger];

    count_StayedCable = length(RealNum_StayedCable);
    ElemNum_StayedCable = zeros(1,count_StayedCable);
    for i=1:count_StayedCable
        ElemNum_StayedCable(i) = MatlabLine2AnsysElem(RealNum_StayedCable(i));
    end
    count_Hanger = length(RealNum_Hanger);
    ElemNum_Hanger = zeros(1,count_Hanger);
    for i=1:count_Hanger
        ElemNum_Hanger(i) = MatlabLine2AnsysElem(RealNum_Hanger(i));
    end
    ElemNum = [ElemNum_StayedCable,ElemNum_Hanger];

    % 计算L2范数
    L2NormOfStrain(Strain_Control,StayedCableRelation,HangerRelation,ReasonableStateBridge,ElemNum)


    % 换回原来的OutputMethod
    ReasonableStateBridge.OutputMethod = OriginalOutputMethod;

end
function L2NormOfStrain(Strain_Control,StayedCableRelation,HangerRelation,ReasonableStateBridge,ElemNum)
    % 1. 控制应变与输入应变对应
    RealNum_StayedCable = StayedCableRelation.RealNum;
    Area_StayedCable = StayedCableRelation.Area;
    count_StayedCable = length(StayedCableRelation.X);

    RealNum_Hanger = HangerRelation.RealNum;
    Area_Hanger = HangerRelation.Area;
    count_Hanger = length(HangerRelation.X);
    
    Strain_Control_StayedCable = Strain_Control(1:count_StayedCable);
    Strain_Control_Hanger = Strain_Control(count_StayedCable+1:count_StayedCable+count_Hanger);
    
    Strain_Output_StayedCable = redistributeStrain(StayedCableRelation,Strain_Control_StayedCable);
    Strain_Output_Hanger = redistributeStrain(HangerRelation,Strain_Control_Hanger);

    % 2. 输出实常数文件
    output_str = ['! StayedCable实常数',newline];
    output_str = [output_str,'/prep7',newline,...
                            outputLinkReal(RealNum_StayedCable,Area_StayedCable,Strain_Output_StayedCable),newline,...
                            '! StayedCable实常数',newline,...
                            outputLinkReal(RealNum_Hanger,Area_Hanger,Strain_Output_Hanger),newline];

    ReasonableStateBridge.OutputMethod.outputAPDL(output_str,'reDefineRealConstant.mac','w')

    % 3. 求解有限元
    % 3.1 删除.lock文件
    deleteFile([ReasonableStateBridge.OutputMethod.JobName,'.lock'],ReasonableStateBridge.OutputMethod.WorkPath); % 删除了.lock文件，本次运行的结果才会覆盖上次运行的结果
    % 3.2 提取应变的宏文件
    output_str = extractStrainByElem(ReasonableStateBridge,ElemNum);
    ReasonableStateBridge.OutputMethod.outputAPDL(output_str,'outputStrain.mac','w')
    % 3.3 求解命令流
    output_str = NewSolutionCommand(ReasonableStateBridge.OutputMethod);
    ReasonableStateBridge.OutputMethod.outputAPDL(output_str,'solveInitialStrain.mac','w')
    % 3.4 求解
    ReasonableStateBridge.run('MacFilePath','solveInitialStrain.mac')
    disp('1+1=2')

    % 4. 提取单元编号和应变

    % 5. 导入Matlab
    % 6. 将输出应变与控制应变对应
    % 7. 获得L2范数
end
function Strain_Control = getControlStrain(Relation)
    Structures = Relation.Structures;
    RowIndex = Relation.RowIndex;
    ColumnIndex = Relation.ColumnIndex;

    Strain_Control = zeros(1,length(RowIndex));

    for i=1:length(RowIndex)
        row = RowIndex{i};
        col = ColumnIndex{i};
        Strain_Structure = zeros(1,length(row));
        for j=1:length(row)
            structure = Structures(row(j));
            Strain_Structure(j) = structure.Strain(col(j));
        end
        Strain_Control(i) = mean(Strain_Structure);
    end
end
function [RealNum,Area] = redistributeRealNumAndArea(Relation)
    Structures = Relation.Structures;
    LineList= Relation.LineList;
    RowIndex = Relation.RowIndex;
    ColumnIndex = Relation.ColumnIndex;
    X = Relation.X;
    len = length(X);
    RealNum = [];
    Area = [];

    for i=1:len
        lines = LineList{i};
        RealNum = [RealNum,[lines.Num]];
        row = RowIndex{i};
        col = ColumnIndex{i};
        for j=1:length(row)
            structure = Structures(row(j));
            AreaList = structure.Section.Area;
            Area = [Area,AreaList(col(j))];
        end
    end
end
function Strain_Output = redistributeStrain(Relation,Strain_Control)
    RowIndex = Relation.RowIndex;
    Strain_Output = [];
    for i=1:length(RowIndex)
        Strain_Output = [Strain_Output,Strain_Control(i)+zeros(1,length(RowIndex{i}))];
    end
end
function output_str = extractStrainByElem(ReasonableStateBridge,Num_Elem)
    count_elem = length(Num_Elem);
    output_str = ['/post1',newline,...
                    sprintf('resume,%s,db',ReasonableStateBridge.OutputMethod.JobName),newline,...
                    'set,1,last',newline,...
                    sprintf('count_elem = %d',count_elem),newline,...
                    ReasonableStateBridge.OutputMethod.outputArray(Num_Elem,'ElemNumArray'),...
                    '*del,elem_output,,NoPr',newline,...
                    '*dim,elem_output,array,count_elem,1',newline,...
                    'etable,Strain_Output,lepel,1',newline,...
                    '*do,i,1,count_elem',newline,...
                    '   num_elem = ElemNumArray(i)',newline,...
                    '   *get,elem_output(i),Elem,num_elem,ETAB,Strain_Output',newline,...
                    '*enddo',newline,...
                    '*cfopen,Strain_Output,txt',newline,...
                    '*vwrite,elem_output(1,1)',newline,...
                    '%%20.8e',newline,...
                    '*cfclos',newline];
end

function output_str = outputLinkReal(Num_list,Area_list,Init_strain_list)
    % 1个LinkReal和1个Line对应
    len = length(Num_list);
    output_str = '';
    for i = 1:len
        output_str = [output_str,sprintf('r,%d,%.6e,%.6e \n',Num_list(i),Area_list(i),Init_strain_list(i))];
    end
end
function output_str = NewSolutionCommand(OutputMethod)
    % 导入实常数
    output_str = [sprintf('resume,%s,db',OutputMethod.JobName),newline,...
                '/input,reDefineRealConstant,mac,,,0',newline,newline];
    % 求解选项设置
    output_str = [output_str,sprintf(['/solu',newline,...
                          'antype,static',newline,...'nropt,full',newline,... % 使用Full Newton-Raphson法求解
                          'nlgeom,on',newline,... % 几何非线性
                          'sstif,on',newline,... % 应力刚度
                          'nsubst,1',newline,... % 荷载子步数
                          'time,1',newline,...
                          'outres,all,last',newline,... % 控制哪些结果需要被输出
                          'solve',newline,...
                          'save,%s,db',newline,...
                          'finish',newline,newline],OutputMethod.JobName)];
    % 后处理导出计算后的应变
    output_str = [output_str,'/input,outputStrain,mac,,,0'];
end
function deleteFile(filename,folder)
    % 删除在folder文件夹下的filename文件
    filepath = fullfile(folder, filename);
    if exist(filepath, 'file')
        delete(filepath);
    end
end