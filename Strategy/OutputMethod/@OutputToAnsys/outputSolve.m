function output_str = outputSolve(obj,options)
    arguments
        obj
        options.nlgeom {mustBeMember(options.nlgeom,{'off','on'})} = 'off'
        options.sstif {mustBeMember(options.sstif,{'off','on'})} = 'off'
        options.nsubst (1,3) {mustBeNumeric} = [0,0,0]
        options.save {mustBeText} = obj.JobName
        options.wrfull (1,1) {mustBeNumeric} = 0 % 第N个荷载步停止分析并导出总刚到.full文件
    end
    output_str = sprintf(['/solu',newline,...
                          'resume,%s,db',newline,...
                          'antype,static',newline,...'nropt,full',newline,... % 使用Full Newton-Raphson法求解
                          'nlgeom,%s',newline,... % 几何非线性
                          'sstif,%s',newline,... % 应力刚度
                          'nsubst,%d,%d,%d',newline,... % 荷载子步数
                          'time,1',newline,...
                          'outres,all,all',newline,... % 控制哪些结果需要被输出
                          'wrfull,%d',newline,...
                          'solve',newline,...
                          'finish'],options.save,options.nlgeom,options.sstif,options.nsubst(1),options.nsubst(2),options.nsubst(3),options.wrfull);
    obj.outputAPDL(output_str,'defSolve.mac','w')
end