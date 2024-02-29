function action(obj,num_column)
    RawData = obj.Txt2RawData(num_column);
    obj.RawData = RawData; 
    obj.NumColumn = num_column;
end