function newobj = clone(obj)
    newobj = Cable();
    Cable.copyProperties(obj,newobj,{'Line','ForcePoint','NewPoint','NewLine'},...
        {@()obj.Line.clone,@()obj.copyForcePoint(newobj),@()newobj.Point.findUnrecord,@()newobj.Line.findUnrecord});
end