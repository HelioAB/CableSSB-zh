function output_str = OutputToAnsys(obj,sec_num)
    output_str = sprintf(['\n' ...
                         'sectype,%d,Beam,CTube \n' ...
                         'secoffset,cent \n' ...
                         'secdata,%E,%E \n'],sec_num, ...
                         obj.Radius_Inner,obj.Radius_Outer);
end