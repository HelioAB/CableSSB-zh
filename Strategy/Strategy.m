classdef Strategy < handle
    properties
        AlgoHandle % function_handle对象，指向需要调用的函数的函数句柄
    end
    methods
        function obj = Stratetgy()
            % obj.AlgoHandle = @Strategy_function
        end
        function set.AlgoHandle(obj,val)
            if isa(val,'function_handle')
                obj.AlgoHandle = val;
            else
                error('AlgoHandle属性必须为function_handle对象')
            end
        end
        function new_obj = clone(obj)
            new_obj = obj.empty;
            meta_class = metaclass(obj);
            properties_Name = {meta_class.PropertyList.Name};
            properties_SetAccess = {meta_class.PropertyList.SetAccess};
            index_SetAccess = strcmp(properties_SetAccess,'public');
            properties_Name = properties_Name(index_SetAccess);
            for i=1:length(properties_Name)
                new_obj(1).(properties_Name{i}) = obj.(properties_Name{i});
            end
        end
    end
    methods(Abstract)
        action(Params_converted)
    end
end