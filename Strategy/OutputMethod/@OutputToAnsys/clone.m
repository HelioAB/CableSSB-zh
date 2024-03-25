function new_obj = clone(obj)
    new_obj = OutputToAnsys();
    new_obj.OutputObj = obj.OutputObj;
    new_obj.AnsysPath = obj.AnsysPath;
    new_obj.WorkPath = obj.WorkPath;
    new_obj.JobName = obj.JobName;
    new_obj.MacFilePath = obj.MacFilePath;
    new_obj.ResultFilePath = obj.ResultFilePath;
end