function output_str = outputAnsysIPC(obj,num_elem)
    if isempty(num_elem)
        error('输入的单元编号数组为空')
    end
    count_elem = length(num_elem);
    str_defElem = obj.OutputMethod.outputArray(num_elem,'num_Elem');
    output_str = [  '! 等待状态文件',newline,...
                    '*create,WaitForFile_Status,bat',newline,...
                    '@echo off',newline,...
                    'setlocal',newline,...
                    ':: 使用传递的参数',newline,...
                    'set "statusFilePath=%%1"',newline,...
                    'set "maxPauseMilliseconds=%%2"',newline,...
                    ':: 检查是否提供了所有必要的参数',newline,...
                    'if "%%1"=="" goto error',newline,...
                    'if "%%2"=="" goto error',newline,...
                    ':: 计时开始',newline,...
                    'set /a waitedMilliseconds=0',newline,...
                    ':loop',newline,...
                    ':: 检查数据文件是否存在且锁定文件是否不存在',newline,...
                    'if not exist "%%statusFilePath%%" goto checkLock',newline,...
                    ':: 文件存在且无锁定，退出循环',newline,...
                    'goto end',newline,...
                    ':checkLock',newline,...
                    ':: 等待指定的毫秒数, 每次等待大概30ms',newline,...
                    'ping 127.0.0.1 -n 1 -w 30 >nul',newline,...
                    ':: 更新等待时间',newline,...
                    'set /a waitedMilliseconds+=30',newline,...
                    ':: 检查是否超过最大等待时间',newline,...
                    'if %%waitedMilliseconds%% lss %%maxPauseMilliseconds%% goto loop',newline,...
                    ':: 超时消息',newline,...
                    'echo Waited Time: %%statusFilePath%% more than %%maxPauseMilliseconds%% milliseconds.',newline,...
                    'goto end',newline,...
                    ':error',newline,...
                    'echo Insufficient parameters provided.',newline,...
                    'echo Usage: script.bat statusFilePath maxPauseMilliseconds',newline,...
                    'goto end',newline,...
                    ':end',newline,...
                    'endlocal',newline,...
                    '*end',newline,newline,...
                    '! 写出求解后结果',newline,...
                    '*create,outputResult,mac',newline,...
                    '/sys,echo. > Result_write.lock',newline,...
                    '*cfopen,Result,txt',newline,...
                    '*vwrite,force(1),Coord_INode(1,1),Coord_INode(1,2),Coord_INode(1,3),Coord_JNode(1,1),Coord_JNode(1,2),Coord_JNode(1,3)',newline,...
                    '(7E20.8)',newline,...
                    '*cfclos',newline,...
                    '/sys,del Result_write.lock',newline,...
                    '*end',newline,newline,...
                    '! 等待MATLAB的分析控制请求,然后读入通知文件中包含的状态信息，存入到loop_status中。通知文件为MATLAB_Call_ANSYS_Analyze.txt',newline,...
                    '*create,waitForAnalyzeCallFromMATLAB,mac',newline,...
                    '/sys,WaitForFile_Status.bat MATLAB_Call_ANSYS_Analyze.txt 20000',newline,...
                    '/sys,echo. > MATLAB_Call_ANSYS_Analyze_read.lock',newline,...
                    '*vread,loop_status(1),MATLAB_Call_ANSYS_Analyze,txt,,ijk,1',newline,...
                    '(1E20.8)',newline,...
                    '/sys,del MATLAB_Call_ANSYS_Analyze_read.lock',newline,...
                    '*end',newline,newline,...
                    '!----------------------------------------------------------------------------------------------------------',newline,...
                    '! 等待 MATLAB_Call_ANSYS_Analyze.txt 文件',newline,...
                    '*dim,loop_status,array,1',newline,...
                    'waitForAnalyzeCallFromMATLAB',newline,...
                    'status = loop_status(1)',newline,...
                    '/sys,del MATLAB_Call_ANSYS_Analyze.txt',newline,newline,...
                    '*dowhile,status ! 如果status==1，就继续下一次循环；如果status==-1，就停止循环。',newline,...
                    '    ! 进行一次分析',newline,...
                    '    /prep7',newline,...
                    '    resume,BaseModel,db',newline,...
                    '    /input,defReal_CableSystem,mac,,,0',newline,...
                    '    /input,defKeyPoint_CableSystem,mac,,,0',newline,...
                    '    /input,defLine_CableSystem,mac,,,0',newline,...
                    '    /input,defLineAttribution_CableSystem,mac,,,0',newline,...
                    '    /input,defLineMesh_CableSystem,mac,,0',newline,...
                    '    /input,defConstraint_CableSystem,mac,,,0',newline,...
                    '    /input,defCoupling_CableSystem,mac,,,0',newline,...
                    '    /solu',newline,...
                    '    antype,static',newline,...
                    '    nlgeom,on',newline,...
                    '    sstif,on',newline,...
                    '    nsubst,1,0,0',newline,... % 已修改
                    '    time,1',newline,...
                    '    outres,all,all',newline,...
                    '    solve',newline,...
                    '    save,TotalModel_TempResult,db',newline,newline,...
                    '    ! 提取并导出求解后的斜拉索力和吊索力',newline,...
                    '    /post1',newline,...
                    '    resume,TotalModel_TempResult,db',newline,...
                    '    set,1,last',newline,newline,...
                    '    ! 单元数目',newline,...
                    '    *del,count_Elem,,NoPr',newline,...
                    sprintf('    count_Elem = %d',count_elem),newline,newline,... % 已修改
                    '    ! 单元编号',newline,...
                    str_defElem,newline,...% 已修改
                    '    ! 单元轴力',newline,...
                    '    *del,force,,NoPr',newline,...
                    '    *dim,force,array,count_Elem',newline,...
                    '    *do,i,1,count_Elem,1',newline,...
                    '        *get,force(i),Elem,num_Elem(i),Smisc,1',newline,...
                    '    *enddo',newline,...
                    '    ! IJ节点位置和位移',newline,...
                    '    *del,Coord_INode,,NoPr',newline,...
                    '    *del,Coord_JNode,,NoPr',newline,...
                    '    *dim,Coord_INode,array,count_Elem,3',newline,...
                    '    *dim,Coord_JNode,array,count_Elem,3',newline,...
                    '    *do,i,1,count_Elem,1',newline,...
                    '       INode = NElem(num_Elem(i),1)',newline,...
                    '       *get,DX,node,INode,U,X',newline,...
                    '       *get,DY,node,INode,U,Y',newline,...
                    '       *get,DZ,node,INode,U,Z',newline,...
                    '       Coord_INode(i,1) = NX(INode) + DX',newline,...
                    '       Coord_INode(i,2) = NY(INode) + DY',newline,...
                    '       Coord_INode(i,3) = NZ(INode) + DZ',newline,...
                    '       JNode = NElem(num_Elem(i),2)',newline,...
                    '       *get,DX,node,JNode,U,X',newline,...
                    '       *get,DY,node,JNode,U,Y',newline,...
                    '       *get,DZ,node,JNode,U,Z',newline,...
                    '       Coord_JNode(i,1) = NX(JNode) + DX',newline,...
                    '       Coord_JNode(i,2) = NY(JNode) + DY',newline,...
                    '       Coord_JNode(i,3) = NZ(JNode) + DZ',newline,...
                    '    *enddo',newline,...
                    '    outputResult',newline,newline,...
                    '    ! 通知MATLAB已经分析完毕',newline,...
                    '    /sys,echo. > ANSYS_Call_MATLAB_ObjFunc.txt',newline,newline,...
                    '    ! 等待MATLAB通知下一次分析',newline,...
                    '    *del,loop_status,,NoPr',newline,...
                    '    *dim,loop_status,array,1',newline,...
                    '    waitForAnalyzeCallFromMATLAB',newline,...
                    '    status = loop_status(1)',newline,...
                    '    /sys,del MATLAB_Call_ANSYS_Analyze.txt ! MATLAB的通知文件阅后即焚',newline,newline,...
                    '*enddo',newline,...
                    'save,TotalModel_LastResult,db'];
    obj.OutputMethod.outputAPDL(output_str,'IPC_ANSYS.mac','w')
end