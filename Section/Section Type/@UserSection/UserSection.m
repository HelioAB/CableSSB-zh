classdef UserSection < SectionData
    % 单位：
    % 参考：https://ansyshelp.ansys.com/account/secured?returnurl=/Views/Secured/corp/v222/en/ans_cmd/Hlp_C_SECDATA.html
    % SubType中的 ASEC
    properties
        A % 面积
        
        Ixx % 绕x轴扭转惯性矩
        Iyy % 绕y轴的抗弯惯性矩
        Izz % 绕z轴的抗弯惯性矩
        Iyz = 0 % 惯性积，衡量刚体转动时离转动轴的距离，当原点在形心时Iyz=0

        Iw = 0 % 翘曲常数
        J = 0.457 % 扭转常数。参考《任意桥梁截面自由扭转常数计算的快速方法 张恒》的矩形截面 J=0.457
        
        CGy = 0 % 中心点的y坐标
        CGz = 0 % 中心点的z坐标

        % 剪心：当荷载作用于剪心时，指产生弯曲不产生扭转。实心截面扭转刚度大且剪心接近形心，可不用管剪心。开口薄壁截面的剪心影响很大。
        SHy = 0 % 剪心的y坐标
        SHz = 0 % 剪心的z坐标

        TKy % 最大宽度(沿y轴的厚度)
        TKz % 最大高度(沿z轴的厚度)

        TSxz = 1 % xz分量的剪力修正系数。梁长l:梁高h越大，越接近1，不考虑深梁则剪力修正系数:=1
        TSxy = 1 % xy分量的剪力修正系数
    end
    methods
        function obj = UserSection(A,Ixx,Iyy,Izz,TKy,TKz)
            arguments
                A (1,1) {mustBePositive}
                Ixx (1,1) {mustBePositive}
                Iyy (1,1) {mustBePositive}
                Izz (1,1) {mustBePositive}
                TKy (1,1) {mustBePositive}
                TKz (1,1) {mustBePositive}
            end
            obj = obj@SectionData('User');
            obj.A = A;
            obj.Iyy = Iyy;
            obj.Izz = Izz;
            obj.Ixx = Ixx;
            obj.TKy = TKy;
            obj.TKz = TKz;
        end
        A = Area(obj)
        output_str = OutputToAnsys(obj,sec_num)
    end
end