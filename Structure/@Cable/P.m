function [P_x,P_y,P_z] = P(obj,Index_Hanger,P_hanger_x,P_hanger_y,P_hanger_z)
    arguments
        obj
        Index_Hanger {mustBeA(Index_Hanger,'logical')} = false(1,length(obj.Point)) % 对于Cable对象，通过index的方式输入Anchor更方便
        P_hanger_x {mustBeNumeric} = []
        P_hanger_y {mustBeNumeric} = []
        P_hanger_z {mustBeNumeric} = []
    end
    obj.Params.Index_Hanger = Index_Hanger;
    [P_x,P_y,P_z] = P@Structure(obj,Index_Hanger,P_hanger_x,P_hanger_y,P_hanger_z);
end