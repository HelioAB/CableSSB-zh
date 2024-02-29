function [line_list] = RawData2LineList(obj) % RawData映射到LineList
    raw_data = obj.RawData;
    X = [raw_data(:,1);raw_data(:,4)]';
    Y = [raw_data(:,2);raw_data(:,5)]';
    Z = [raw_data(:,3);raw_data(:,6)]';
    raw_point_0 = Point([],X,Y,Z);
    raw_point_1 = raw_point_0.merge();
    raw_point_1.serialize();
    len = length(raw_point_1);
    line_list = Line([],raw_point_1(1:len/2),raw_point_1(len/2+1:len));
end