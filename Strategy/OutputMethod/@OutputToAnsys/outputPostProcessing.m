function output_str = outputPostProcessing(obj,params)
    output_str = ['/post1',newline,...
                  sprintf('resume,%s,db',obj.JobName),newline,...
                  'set,1,last',newline,newline];
    
    output_str = [output_str,getBendingStrainEnergyData(obj,params)];
    obj.outputAPDL(output_str,'defPostProcessing.mac','w');
    
end
function output_str = getBendingStrainEnergyData(obj,params)
    
end
