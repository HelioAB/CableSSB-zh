fid = fopen('.\DesignVariable.txt','r');
variable = fscanf(fid,'%f%f',[1,2]);
fclose(fid);
mean = (variable(1)+variable(2))/2;
fid = fopen('.\DesignVariable_Changed.txt','w');
fprintf(fid,'%5.2f',mean);
fclose(fid);
