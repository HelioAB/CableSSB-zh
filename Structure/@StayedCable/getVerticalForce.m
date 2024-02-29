function Vertical_Force = getVerticalForce(obj)
    Internal_Force = obj.InternalForce;
    dir_tower_tension= obj.getStayedCableTensionDirectionAtTower();
    Vertical_Force = Internal_Force.*dir_tower_tension(:,3)';
end