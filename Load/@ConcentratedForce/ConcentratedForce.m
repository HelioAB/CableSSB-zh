classdef ConcentratedForce< Load
    methods
        function obj = ConcentratedForce(apply_point,direction,value)
            arguments
                apply_point (1,:) {mustBeA(apply_point,{'Point'})} = Point.empty
                direction {mustBeMember(direction,{'X','Y','Z','None'})} = 'None'
                value {mustBeNumeric} = [] % 可能的输入：1. 输入一个数，表示所有作用点都是相同的力；2. 输入和作用点等长度的数
            end
            if ~isempty(apply_point)
                converted_value = ConcentratedForce.convertValueSize(apply_point,value);
            else
                converted_value = {};
            end
            obj = obj@Load(apply_point,direction,converted_value,'Concentrated Load');
        end
        arrow_handle = plot(obj,options)
    end
    methods(Static)
        function Value = convertValueSize(apply_point,val)
            len = length(apply_point);
            if length(val)==1
                val = zeros(1,len)+val;
            elseif length(val)==len
                
            else
                error('创建Load类时输入的value值，其长度一定要与作用点个数相同或为1')
            end
            Value = cell(1,len);
            for i=1:len
                Value{i} = val(i);
            end
        end
    end
end