function material_data_struct = outputToAnsys(obj) % 输出一个struct，记录了所有材料参数的参数名和参数值。
    material_data_struct.Ex = obj.E;
    material_data_struct.prxy = obj.prxy;
    material_data_struct.dens = obj.density;
    material_data_struct.alpx = obj.alpha_x;
end