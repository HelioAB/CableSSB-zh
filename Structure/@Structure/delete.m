function delete(obj)
    % delete析构函数的调用顺序：先调用子类的析构函数，再调用父类的析构函数
    % 子类的析构函数仅为父类析构函数的扩充
    % 因此这里的delete方法是handle类中delete方法的扩充，既能unrecord(obj)又能delete(obj)
    obj.unrecord();
end