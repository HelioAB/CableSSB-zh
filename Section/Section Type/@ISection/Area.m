function A = Area(obj)
    w1 = obj.Width_TopFlange; % 上翼缘的宽度（两肢而不是一肢）
    w2 = obj.Width_BottomFlange; % 下翼缘的宽度
    w3 = obj.Depth; % 上翼缘端到下翼缘端之间的距离
    t1 = obj.Thickness_TopFlange; % 上翼缘的厚度
    t2 = obj.Thickness_BottomFlange; % 下翼缘的厚度
    t3 = obj.Thickness_Web; % 腹板厚度
    A = w1*t1 + w2*t2 + w3*t3 - t1*t3 - t2*t3; 
end