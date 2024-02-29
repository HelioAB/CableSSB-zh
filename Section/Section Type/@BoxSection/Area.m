function A = Area(obj)
    w = obj.Width_Outer; % 箱型截面外缘宽度
    h = obj.Height_Outer; % 箱型截面外缘高度
    t1 = obj.Thickness_Web1; % 腹板(单元坐标系-y方向)的厚度
    t2 = obj.Thickness_Web2; % 腹板(单元坐标系+y方向)的厚度
    t3 = obj.Thickness_BottomBoard; % 底板(单元坐标系-z方向)厚度
    t4 = obj.Thickness_TopBoard; % 顶板(单元坐标系+z方向)厚度
    A = w*h - (w-t1-t2)*(h-t3-t4);% 待定
end