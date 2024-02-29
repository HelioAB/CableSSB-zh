function Num = PointNum2Num(obj,Index)
    % 在父类Structure中PointNum2Num方法 输入数字，输出数字
    % Cable类中PointNum2Num方法 输入logical，输出数字
    if length(Index) == length(obj.Point)-2
        index = [false,Index,false];
    elseif length(Index) == length(obj.Point)
        index = Index;
    else
        error('请输入正确长度的锚固点索引向量Index_Force, 应为length(obj.Point)-2 或 length(obj.Point)其中之一')
    end
    Num = [obj.Point(index).Num];
end