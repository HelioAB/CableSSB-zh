function output_str = outputArray(obj,array,array_name)
    arguments
        obj
        array (1,:) {mustBeNumeric}
        array_name (1,:) {mustBeText}
    end
    count = length(array);
    num_array = ceil(count/18);
    length_end_array = mod(count,18);
    
    output_str = [sprintf('*del,%s,,NoPr',array_name),newline,sprintf('*dim,%s,array,%d',array_name,count),newline];
    for i=1:num_array
        output_str = [output_str,sprintf('%s(%d)=',array_name,(i-1)*18+1)];
        if i~=num_array
            count_end = 18;
        elseif length_end_array ~= 0
            count_end = length_end_array;
        elseif length_end_array == 0
            count_end = 18;
        end
        for j=1:count_end
            output_str = [output_str,num2str(array((i-1)*18+j)),','];
        end
        output_str = [output_str,newline];
    end
end