function I = Iyy(obj)
    b_outer = obj.Width_Outer;
    h_outer = obj.Height_Outer;
    b_inner = b_outer-obj.Thickness_Web1-obj.Thickness_Web2;
    h_inner = h_outer-obj.Thickness_BottomBoard-obj.Thickness_TopBoard;
    I = (b_outer*h_outer^3-b_inner*h_inner^3)/12;
end