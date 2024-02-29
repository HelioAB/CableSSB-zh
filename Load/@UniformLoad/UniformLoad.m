classdef UniformLoad < Load
    methods
        function obj = UniformLoad(apply_line,direction,value)
            arguments
                apply_line (1,:) {mustBeA(apply_line,{'Line'})} = Line.empty
                direction {mustBeMember(direction,{'X','Y','Z','None'})} = 'None'
                value (1,1) {mustBeNumeric} = 0
            end
            if ~isempty(apply_line)
                converted_value = UniformLoad.convertValueSize(apply_line,value);% UniformLoad对象输入的value为：1*1的double
            else
                converted_value = {};
            end
            obj = obj@Load(apply_line,direction,converted_value,'Distributed Load'); % Load对象输入的value为：和application等长度的cell
        end
        arrow_handle = plot(obj,options)
        
    end
    methods(Static)
        function Value = convertValueSize(apply_line,val)
            len = length(apply_line);
            Value = cell(1,len);
            for i=1:len
                Value{i} = val;% 均布荷载，所以Value的每一个元素都是一个1*1的double
            end
        end
    end
end