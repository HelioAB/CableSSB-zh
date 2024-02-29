function strain = getStrain(obj)
    strain = (obj.Line.LineLength - obj.UnstressedLength) ./ obj.UnstressedLength;
end