function [status,cmdout] = runMac(obj,options)
    arguments
        obj
        options.ComputingMode {mustBeMember(options.ComputingMode,{'Distributed','Shared-Memory'})} = 'Shared-Memory'
        options.AnsysExePath = obj.AnsysPath
        options.WorkPath = obj.WorkPath
        options.JobName = obj.JobName
        options.MacFilePath = obj.MacFilePath
        options.ResultFilePath = obj.ResultFilePath
    end
    % 输出路径转换为command的格式, 默认是obj的属性位置，但是也可以更换
    Ansys_exe_path = OutputToAnsys.convertPath(options.AnsysExePath);
    work_path = OutputToAnsys.convertPath(options.WorkPath);
    job_name = OutputToAnsys.convertPath(options.JobName);
    APDL_file_path = OutputToAnsys.convertPath(options.MacFilePath);
    result_file_path = OutputToAnsys.convertPath(options.ResultFilePath);
    % 运行Ansys
    % 如果用Distributed Computing: '-lch -p ansys -dis -mpi INTELMPI -np 4 ',
    %       用Distributed Computing会生成JobName.out、JobName0.out、JobName1.out、JobName2.out等
    % 如果用Shared-Memory Parallel: '-lch -p ansys -smp -np 4 '
    %       用Shared-Memory Parallel只生成JobName.out
    if strcmp(options.ComputingMode,'Distributed')
        str_ComputingMode = '-lch -p ansys -dis -mpi INTELMPI -np 4 ';
    elseif strcmp(options.ComputingMode,'Shared-Memory')
        str_ComputingMode = '-lch -p ansys -smp -np 4 ';
    end
    system_str = strcat([Ansys_exe_path,' '...
                  str_ComputingMode ... 
                  '-dir ',work_path,' '...
                  '-j ',job_name,' '...
                  '-i ',APDL_file_path,' '...
                  '-o ',result_file_path,' ' ...
                  '-b -l en-us -s read' ...
                  '-m 2300 -db 1024']);
    [status,cmdout] = system(system_str);
end