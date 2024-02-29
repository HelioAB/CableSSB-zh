obj = bridge_state;
cable = obj.ReplacedCable(1);
hanger = cable.findConnectStructureByClass('Hanger');
exitflag = 2;
x0 = zeros(1,length(hanger.Line));
fval = 100;
step = 1;
while (fval>1e-4) && (exitflag==2) && (step>1e-12) % 如果停止了并且fval还比较大，就减小DiffMinChange为原来的0.01
    [x1,fval,exitflag] = solveHangerTopCoord(cable,hanger,obj,"x0",x0,"MinDiffChange",step,'MaxIteration',100);
    x0 = x1;
    step = step*0.001;
end