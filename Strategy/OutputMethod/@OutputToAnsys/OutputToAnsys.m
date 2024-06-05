classdef OutputToAnsys < OutputTo
    properties
        AnsysPath
        WorkPath
        JobName
        MacFilePath
        ResultFilePath
        Params
        PostProcessingPath = struct
    end
    methods
        function obj = OutputToAnsys(OutputObj,options)
            arguments
                OutputObj = Bridge.empty
                options.AnsysPath (1,:) {mustBeTextScalar} = 'C:\Program Files\ANSYS Inc\ANSYS Student\v232\ansys\bin\winx64\MAPDL.exe'
                options.WorkPath (1,:) {mustBeTextScalar} = ''
                options.JobName (1,:) {mustBeTextScalar} = 'JobName'
                options.MacFilePath (1,:) {mustBeTextScalar} = ''
                options.ResultFilePath (1,:) {mustBeTextScalar} = ''
            end
            % 继承
            obj = obj@OutputTo(OutputObj);
            if ~isempty(options.WorkPath)
                if isempty(options.MacFilePath)
                    options.MacFilePath = fullfile(options.WorkPath,'main.mac');
                end
                if isempty(options.ResultFilePath)
                    options.ResultFilePath = fullfile(options.WorkPath,'result.out');
                end
            end
            % 成员属性赋值
            obj.AnsysPath = OutputToAnsys.convertTextToChar(options.AnsysPath);
            obj.WorkPath = OutputToAnsys.convertTextToChar(options.WorkPath);
            obj.JobName = OutputTo.convertTextToChar(options.JobName);
            obj.MacFilePath = OutputToAnsys.convertTextToChar(options.MacFilePath);
            obj.ResultFilePath = OutputToAnsys.convertTextToChar(options.ResultFilePath);
        end
        new_obj = clone(obj);
        action(obj,options);
        [status,cmdout] = runMac(obj,options)
        outputAPDL(obj,output_str,file_name,output_method)
        output_str = outputConstraint(obj);
        output_str = outputCoupling(obj);
        output_str = outputElementType(obj);
        output_str = outputKeyPoint(obj);
        output_str = outputLine(obj);
        output_str = outputLineAttribution(obj);
        output_str = outputLineMesh(obj);
        output_str = outputLoad(obj);
        output_str = outputMaterial(obj);
        output_str = outputReal(obj);
        output_str = outputSection(obj);
        output_str = outputSolve(obj,options);
        output_str = outputPostProcessing(obj,params);
        output_str = outputMain(obj);
        output_str = outputArray(obj,array,array_name); % 由于给Ansys中的一个数组赋值最多只能赋值18个数，因此需要将一个数组拆成多个数组
        outputReasonalStateOptim(obj)

        % 输出获取Ansys中某些数据的命令流，输入参数：obj,quaryObj,DAtaBasePath 输出参数：ResultFilePath
        [nodes,elements] = getAllNodesAndAllElements(obj)
        [inodes,jnodes,knodes] = getNodeByNumElements(obj,Num_Elems)
        FiniteElementModel = getFiniteElementModel(obj)
        ResultFilePath = getBendingStrainEnergy(obj,structure,DataBasePath)
        data = getDisplacementFromAnsys(obj,num_MonitoredNodes)
        data = getInternalForceFromAnsys(obj,num_MonitoredElems_Link,num_MonitoredElems_Beam)
        [OutputMethod_clone,num_GirderNodes] = analyzeInfluenceLine(obj,num_GirderNodes,value_Force)
        data = getInfluenceLineFromAnsys(obj,OutputMethodObj_analyzeInfluenceLine,num_GirderNodes,num_MonitoredNodes,num_MonitoredElems_Link,num_MonitoredElems_Beam)
        bridgeobj = loadBridgeObj(obj,options)
        [data,nodes,elems_link,elems_beam] = loadResults(obj,options)
    end
    methods(Static)
        function workspace_path = createWorkSpace(NewFolderName,ParentFolder)
            arguments
                NewFolderName (1,:) {mustBeText} = 'Ansys_WorkSpace'
                ParentFolder (1,:) {mustBeText} = obj.CurrentPath
            end
            [status, msg, msgID] = mkdir(ParentFolder,NewFolderName);
            workspace_path = [ParentFolder,'\',NewFolderName];
        end
        function converted_text = convertPath(text)
            text = OutputTo.convertTextToChar(text);
            converted_text = ['"',text,'"'];
        end
        function joined_path = joinPath(path1,path2)
            path1 = OutputTo.convertTextToChar(path1);
            path2 = OutputTo.convertTextToChar(path2);
            path = strcat(path1,path2);
            joined_path = ['"',path,'"'];
        end
    end
end