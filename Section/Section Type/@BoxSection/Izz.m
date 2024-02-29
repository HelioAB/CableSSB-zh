function I = Izz(obj)
    h_outer = obj.Width_Outer;
    b_outer = obj.Height_Outer;
    h_inner = h_outer-obj.Thickness_Web1-obj.Thickness_Web2;
    b_inner = b_outer-obj.Thickness_BottomBoard-obj.Thickness_TopBoard;
    I = (b_outer*h_outer^3-b_inner*h_inner^3)/12;
end