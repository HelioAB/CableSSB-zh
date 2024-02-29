classdef SectionData < handle
    % 单位：kN,m
    % 具体的各种截面参数定义参考Ansys的SecData命令用户手册的：
    % https://ansyshelp.ansys.com/account/secured?returnurl=/Views/Secured/corp/v222/en/ans_cmd/Hlp_C_SECDATA.html
    properties
        SectionType
    end
    methods
        function obj = SectionData(SectionType)
            arguments
                SectionType (1,:) {mustBeText}
            end
            obj.SectionType = SectionType;
        end
        tf = isempty(obj)
        A = Area(obj)
    end
    methods(Abstract)
        section_data_struct = OutputToAnsys(obj)
    end
end