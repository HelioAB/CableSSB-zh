function internal_force = InternalForce(obj)
    internal_force = obj.Material.MaterialData.E .* obj.Strain .* obj.Section.Area;
end