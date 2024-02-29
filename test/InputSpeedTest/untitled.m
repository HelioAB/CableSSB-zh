clear all
clc
file_path = 'C:\Users\Huawei\Desktop\Matlab OOP\Susp\Susp V.4\Output Files\findState\stiff.txt';
input_method = InputStiffMatrix(file_path);
input_method.action

A = input_method.StiffMatrix;
b = input_method.RHS;
x = A\b; % 太快了

% 计算总弯曲应变能



