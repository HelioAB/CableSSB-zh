function [status,cmdout] = run(obj,options)
    arguments
        obj
        options.ComputingMode {mustBeMember(options.ComputingMode,{'Distributed','Shared-Memory'})} = 'Shared-Memory'
        options.AnsysExePath = obj.OutputMethod.AnsysPath
        options.WorkPath = obj.OutputMethod.WorkPath
        options.JobName = obj.OutputMethod.JobName
        options.MacFilePath = obj.OutputMethod.MacFilePath
        options.ResultFilePath = obj.OutputMethod.ResultFilePath
    end
    [status,cmdout] = obj.OutputMethod.runMac('ComputingMode',options.ComputingMode,...
                                              'AnsysExePath',options.AnsysExePath,...
                                              'WorkPath',options.WorkPath, ...
                                              'JobName',options.JobName,...
                                              'MacFilePath',options.MacFilePath,...
                                              'ResultFilePath',options.ResultFilePath);
end