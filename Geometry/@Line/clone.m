function newobj = clone(obj)
    % 在复制Line对象时，会连同Point对象一起新建复制
    [unipoint,index_IPoint,index_JPoint] = obj.uniPoint();

    copy_point = unipoint.clone;
    newobj = Line([],copy_point(index_IPoint),copy_point(index_JPoint));
end