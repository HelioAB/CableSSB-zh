function x_solveInitialStrain(obj,OutputMethod)
    arguments
        obj
        OutputMethod {mustBeA(OutputMethod,'OutputToAnsys')} = obj.OriginalBridge.OutputMethod;
    end

    % 1. 获得理想中的合理成桥状态
    ReasonableStateBridge = obj.OriginalBridge;
    OriginalOutputMethod = ReasonableStateBridge.OutputMethod;
    ReasonableStateBridge.OutputMethod = OutputMethod; % 更换OutputMethod
%     ReasonableStateBridge.output;
%     ReasonableStateBridge.run;

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
    [Strain_Control_StayedCable,index_StayedCable] = getControlStrain(StayedCableRelation);
    StayedCableRelation.Index = index_StayedCable;

    [LineList,X,RowIndex,ColumnIndex] = Hangers.getSameGirderXLine;
    HangerRelation = struct('Structures',Hangers,'LineList',{LineList},'X',X,'RowIndex',{RowIndex},'ColumnIndex',{ColumnIndex});
    [RealNum_Hanger,Area_Hanger] = redistributeRealNumAndArea(HangerRelation);
    HangerRelation.RealNum = RealNum_Hanger;
    HangerRelation.Area = Area_Hanger;
    [Strain_Control_Hanger,index_Hanger] = getControlStrain(HangerRelation);
    HangerRelation.Index = index_Hanger;

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

    % 输出迭代求解的Mac文件
    output_str = outputControlMac(obj,ReasonableStateBridge,Strain_Control,StayedCableRelation,HangerRelation,ElemNum);

    % 换回原来的OutputMethod
    ReasonableStateBridge.OutputMethod = OriginalOutputMethod;
end
function output_str = outputControlMac(obj,ReasonableStateBridge,Strain_Control,StayedCableRelation,HangerRelation,ElemNum)
    OutputMethod = ReasonableStateBridge.OutputMethod;
    output_str = [sprintf('resume,%s,db',OutputMethod.JobName),newline,newline];
    
    % 1. 目标应变
    output_str = [output_str,'! 目标应变',newline];
    output_str = [output_str,outputArray(Strain_Control,'Strain_Objective','%.6e'),newline];

    % 2. 控制应变，设置初值与目标应变相等
    output_str = [output_str,'! 控制应变',newline];
    output_str = [output_str,outputArray(Strain_Control,'Strain_Control','%.6e'),newline];

    % 3. 控制应变到输入应变的索引
    output_str = [output_str,'! 控制应变到输入应变的索引',newline];
    index_StayedCable = StayedCableRelation.Index;
    index_Hanger = HangerRelation.Index + length(StayedCableRelation.X);
    index = [index_StayedCable,index_Hanger];
    output_str = [output_str,outputArray(index,'ControlToInput','%d'),newline];

    % 5. 实常数编号
    output_str = [output_str,'! 实常数编号',newline];
    RealNum = [StayedCableRelation.RealNum,HangerRelation.RealNum];
    output_str = [output_str,outputArray(RealNum,'RealNum','%d'),newline];

    % 6. 面积
    output_str = [output_str,'! 面积',newline];
    Area = [StayedCableRelation.Area,HangerRelation.Area];
    output_str = [output_str,outputArray(Area,'Area','%d'),newline];

    % 7. 循环
    output_str = [output_str,'*do,i,1,10',newline];

    % 4. 输入应变
    output_str = [output_str,'! 输入应变',newline];
    output_str = [output_str,'*del,Strain_Input,,NoPr',newline,...
                            'count_Strain_Input = count_ControlToInput',newline,...
                            '*dim,Strain_Input,array,count_Strain_Input',newline,...
                            '*do,j,1,count_Strain_Input',newline,...
                            '    index = ControlToInput(j)',newline,...
                            '    Strain_Input(j) = Strain_Control(index)',newline,...
                            '*enddo',newline,newline];


    % 8. 重新定义初应变
    output_str = [output_str,'! 重新定义初应变',newline];
    output_str = [output_str,'*do,j,1,count_RealNum',newline,...
                             '    r,RealNum(j),Area(j),Strain_Input(j)',newline,...
                             '*enddo',newline];

    % 9. 求解选项设置
    output_str = [output_str,'! 求解选项设置',newline];
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

    % 10. 提取分析之后的应变
    output_str = [output_str,'! 提取分析之后的应变',newline];
    output_str = [output_str,'/post1',newline,...
                    sprintf('resume,%s,db',OutputMethod.JobName),newline,...
                    'set,1,last',newline,...
                    outputArray(ElemNum,'ElemNumArray','%d'),...
                    '*del,Strain_Output,,NoPr',newline,...
                    '*dim,Strain_Output,array,count_ElemNumArray,1',newline,...
                    'etable,Strain,lepel,1',newline,...
                    '*do,j,1,count_ElemNumArray',newline,...
                    '   num_elem = ElemNumArray(j)',newline,...
                    '   *get,Strain_Output(j),Elem,num_elem,ETAB,Strain',newline,...
                    '*enddo',newline];

    % 11. 输出应变到控制应变的索引
    output_str = [output_str,'! 输出应变到控制应变的索引',newline];
    output_str = [output_str,outputArray(1:2:length(index),'OutputToControl','%d'),newline];

    % 12. 取出相应的输出应变
    output_str = [output_str,'! 取出相应的输出应变',newline];
    output_str = [output_str,'*del,Strain_Output_Control,,NoPr',newline,...
                            'count_Strain_Output_Control = count_OutputToControl',newline,...
                            '*dim,Strain_Output_Control,array,count_Strain_Output_Control',newline,...
                            '*do,j,1,count_Strain_Output_Control',newline,...
                            'index = OutputToControl(j)',newline,...
                            'Strain_Output_Control(j) = Strain_Output(index)',newline,...
                            '*enddo',newline];
    
    % 12. 判定条件
    output_str = [output_str,'! 判定条件',newline];
    output_str = [output_str,'Err_Strain_Control = 0',newline,...
                            '*do,j,1,count_Strain_Output_Control',newline,...
                            'Err = abs((Strain_Output_Control(j)-Strain_Control(j))/Strain_Control(j))',newline,...
                            '*if,Err_Strain_Control,GT,Err,THEN',newline,...
                            '    max_value=Err_Strain_Control',newline,...
                            '*endif',newline,...
                            '*if,Err,GT,Err_Strain_Control,THEN',newline,...
                            '    max_value=Err',newline,...
                            '*endif',newline,...
                            'Err_Strain_Control = max_value',newline,...
                            '*enddo',newline];
    
    % 13. 更新应变
    output_str = [output_str,'! 更新应变',newline];
    output_str = [output_str,'*do,j,1,count_Strain_Output_Control',newline,...
                            '    Strain_Control(j) = Strain_Control(j) + Strain_Output_Control(j) - Strain_Objective(j)',newline,...
                            '*enddo',newline];

    % 14. 结束循环
    output_str = [output_str,'*enddo',newline];

    OutputMethod.outputAPDL(output_str,'solveInitialStrain.mac','w')


end

function [Strain_Control,index] = getControlStrain(Relation)
    Structures = Relation.Structures;
    RowIndex = Relation.RowIndex;
    ColumnIndex = Relation.ColumnIndex;

    Strain_Control = zeros(1,length(RowIndex));
    index = [];

    for i=1:length(RowIndex)
        row = RowIndex{i};
        col = ColumnIndex{i};
        Strain_Structure = zeros(1,length(row));
        for j=1:length(row)
            structure = Structures(row(j));
            Strain_Structure(j) = structure.Strain(col(j));
            index = [index,i];
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
                    outputArray(Num_Elem,'ElemNumArray'),...
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
function output_str = outputArray(array,array_name,ValueFormat)
    arguments
        array (1,:) {mustBeNumeric}
        array_name (1,:) {mustBeText}
        ValueFormat (1,:) {mustBeText}
    end
    count = length(array);
    num_array = ceil(count/18);
    length_end_array = mod(count,18);
    
    output_str = [sprintf('*del,%s,,NoPr',array_name),newline,...
                  sprintf('count_%s = %d',array_name,count),newline,...
                  sprintf('*dim,%s,array,count_%s',array_name,array_name),newline];
    for i=1:num_array
        output_str = [output_str,sprintf('%s(%d)=',array_name,(i-1)*18+1)];
        if i~=num_array
            count_end = 18;
        else
            count_end = length_end_array;
        end
        for j=1:count_end
            output_str = [output_str,sprintf(ValueFormat,array((i-1)*18+j)),','];
        end
        output_str = [output_str,newline];
    end
end