function line_list = action(obj)
    obj.txtToRawData;
    line_list =  obj.RawData2LineList();
    obj.LineList = line_list;
end