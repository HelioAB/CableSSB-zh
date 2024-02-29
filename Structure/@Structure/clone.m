function newobj = clone(obj,options)
    arguments
        obj (1,1)
        options.SpecialCopyProps = {'Line','ForcePoint','connect_point','NewPoint','NewLine'}
        options.SpecialCopyMethod
    end
    newobj = obj.empty;
    newobj(1).Description = '';% 新建一个可以重新赋值属性的对象newobj
    % 经过copyProperties方法中转，可以重构copyProperties来使用不同的方法复制Properties
    Structure.copyProperties(obj,newobj,options.SpecialCopyProps,...
        {@()obj.Line.clone,@()obj.copyForcePoint(newobj),@()obj.copyConnectPoint(),@()newobj.Point.findUnrecord,@()newobj.Line.findUnrecord});
    
    obj.RelatedToStructure = struct('RelatedStructure',newobj,'Relation','Cloned','RelationData',[]);
    newobj.RelatedToStructure = struct('RelatedStructure',obj,'Relation','Cloned','RelationData',[]);
end