classdef OutputTo < Strategy
    properties
        OutputObj
    end
    methods
        function obj = OutputTo(OutputObj)
            arguments
                OutputObj {mustBeA(OutputObj,'Bridge')}
            end
            obj.OutputObj = OutputObj;
        end
        function current_path = CurrentPath(obj)
            current_path = cd;
        end
        
    end
    methods(Abstract)
        action(obj)
    end
    methods(Static)
        function text = convertTextToChar(text)
            % 3种情况：
            %   1. 'text'
            %   2. '"text"'
            %   3. "text"
            % 情况1,2,3均转换成 'text'
            if isa(text,'char')
                splitted_text = split(text,'"');
                sz = size(splitted_text);
                if sz(1) == 1
                elseif sz(1) == 3
                    text = splitted_text{2};
                else
                    error('请输入正确的path格式')
                end
            elseif isa(text,'string')
                text = char(text);
            else

            end
        end
    end
end